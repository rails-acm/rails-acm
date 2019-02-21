module Rails::Acm
  class ReissuesCertificate
    DEFAULT_SLEEP_INTERVAL = 1
    DNS_RECORD_TTL = 60
    DNS_SLEEP_INTERVAL = DNS_RECORD_TTL + DEFAULT_SLEEP_INTERVAL

    include Callable

    attr_reader :keypair, :acme_client, :route53

    def initialize(keypair:, directory: nil, aws_region: "eu-west-1")
      @keypair = keypair

      @acme_client = if directory
        keypair.acme_identity.acme_client(
          directory: directory
        )
      else
        keypair.acme_identity.acme_client
      end

      @route53 = Aws::Route53::Client.new(region: aws_region)
    end

    def call
      if keypair.identifiers.empty?
        raise Rails::Acm::NoIdentifiersForKeypairError, "no-identifiers-for-keypair rails_acm_ssl_keypair_id=#{keypair.id}"
      end

      order = acme_client.new_order(identifiers: keypair.identifiers)

      order.authorizations.each do |authorization|
        domain_name = keypair
          .domain_names
          .where(hostname: [
            authorization.domain,
            "*.#{authorization.domain}"
          ]).first

        unless domain_name
          Rails.logger.error "unable-to-find-domain-name-for-authorization "\
            "hostname=#{authorization.domain}"
          next
        end

        if authorization.http
          Rails.logger.info "creating-http-challenge "\
            "domain_name_id=#{domain_name.id} "\
            "hostname=#{domain_name.hostname}"

          create_http_challenge(domain_name, authorization.http)
          authorization.http.request_validation
          wait_for_validation(authorization.http)
        else
          Rails.logger.info "creating-dns-challenge "\
            "domain_name_id=#{domain_name.id} "\
            "hostname=#{domain_name.hostname}"

          update_dns(domain_name, authorization.dns)
          sleep DNS_SLEEP_INTERVAL
          authorization.dns.request_validation
          wait_for_validation(authorization.dns)
        end
      end

      finalize_order(order)
    end

    private

    def create_http_challenge(domain_name, challenge)
      domain_name.http_challenges.create!(
        file_content: challenge.file_content,
        filename: challenge.filename,
        token: challenge.token
      )
    end

    def update_dns(domain_name, challenge)
      # TODO: make this work for non-wildcard domains
      challenge_record_name = challenge.record_name +
        domain_name.hostname.tr("*", "")

      route53.change_resource_record_sets({
        hosted_zone_id: domain_name.route_53_hosted_zone_id,
        change_batch: {
          changes: [
            {
              action: "UPSERT",
              resource_record_set: {
                name: challenge_record_name,
                type: challenge.record_type,
                ttl: DNS_RECORD_TTL,
                resource_records: [{
                  value: "\"#{challenge.record_content}\""
                }]
              }
            }
          ]
        }
      })
    end

    def wait_for_validation(challenge)
      while challenge.status == "pending"
        sleep DEFAULT_SLEEP_INTERVAL
        challenge.reload
        Rails.logger.info "challenge-status status='#{challenge.status}' url='#{challenge.url}'"
      end

      unless challenge.status == "valid"
        raise Rails::Acm::ChallengeValidationError, "invalid-challenge status='#{challenge.status}' url='#{challenge.url}'"
      end
    end

    def finalize_order(order)
      Rails.logger.info "order-status status='#{order.status}'"

      csr = Acme::Client::CertificateRequest.new(
        private_key: keypair.rsa_key,
        subject: {common_name: keypair.identifiers.first},
        names: keypair.identifiers
      )

      keypair.update!(certificate_signing_request: csr)
      order.finalize(csr: csr)

      sleep DEFAULT_SLEEP_INTERVAL while order.status == "processing"

      keypair.update!(certificate: order.certificate)
    end
  end
end
