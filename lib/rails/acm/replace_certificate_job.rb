module Rails::Acm
  class ReplaceCertificateJob < ActiveJob::Base
    queue_as{ Rails::Acm.job_queue }

    def perform(heroku_ssl_endpoint)
      ReplacesEndpointCertificate.call(endpoint: heroku_ssl_endpoint,
                                       keypair: heroku_ssl_endpoint.ssl_keypair)
    end
  end
end
