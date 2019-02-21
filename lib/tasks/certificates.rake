namespace :certificates do
  desc "check expiration dates for ssl certificates and schedule replacement "\
    "if expiring soon"
  task check_for_expiration: :environment do
    Rails::Acm::HerokuSslEndpoint.find_each do |endpoint|
      if endpoint.expiring_soon?
        Rails.logger.info "enqueueing-certificate-replacement "\
          "heroku_ssl_endpoint_id=#{endpoint.id}"

        Rails::Acm::ReissueCertificateJob.perform_later(endpoint)
      else
        Rails.logger.info "skipping-certificate-replacement "\
          "heroku_ssl_endpoint_id=#{endpoint.id}"
      end
    end
  end

  desc "force a reissue and renewal for all endpoints"
  task force_renew: :environment do
    Rails::Acm::HerokuSslEndpoint.find_each do |endpoint|
      Rails.logger.info "enqueueing-certificate-replacement "\
        "heroku_ssl_endpoint_id=#{endpoint.id}"
      Rails::Acm::ReissueCertificateJob.perform_later(endpoint)
    end
  end
end
