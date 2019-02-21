module Rails::Acm
  class ReplacesEndpointCertificate
    include Callable

    attr_reader :endpoint, :keypair, :heroku_client

    def initialize(endpoint:, keypair:, heroku_client: nil)
      @endpoint, @keypair = endpoint, keypair
      @heroku_client = heroku_client || PlatformAPI.connect_oauth(
        ENV['HEROKU_API_TOKEN'])
    end

    def call
      response = heroku_client.send(endpoint.endpoint_type).update(
        endpoint.heroku_app_id,
        endpoint.heroku_endpoint_id,
        {'certificate_chain' => keypair.certificate,
         'private_key' => keypair.private_key})

      Rails.logger.info "updated-endpoint "\
        "heroku_ssl_endpoint_id=#{endpoint.id} "\
        "heroku_app_id=#{endpoint.heroku_app_id} "\
        "heroku_endpoint_id=#{endpoint.heroku_endpoint_id} "\
        "response='#{response.inspect}'"

      response
    end
  end
end
