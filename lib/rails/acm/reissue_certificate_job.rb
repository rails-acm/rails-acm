require 'rails/acm/replace_certificate_job'

module Rails::Acm
  class ReissueCertificateJob < ActiveJob::Base
    queue_as{ Rails::Acm.job_queue }

    def perform(heroku_ssl_endpoint)
      ReissuesCertificate.call(keypair: heroku_ssl_endpoint.ssl_keypair)

      ReplaceCertificateJob.perform_later(heroku_ssl_endpoint)
    end
  end
end
