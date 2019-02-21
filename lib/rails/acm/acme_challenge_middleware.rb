module Rails::Acm
  class AcmeChallengeMiddleware
    unless const_defined?(:ACME_PREFIX)
      ACME_PREFIX = "/.well-known/acme-challenge/".freeze
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"].start_with?(ACME_PREFIX)
        token = env["PATH_INFO"].sub(ACME_PREFIX,"")
        acme_challenge = HttpChallenge.find_by(token: token)

        unless acme_challenge
          return [404, {}, []]
        end

        return [200, { "Content-Type" => "text/plain" }, [acme_challenge.file_content]]
      end

      @app.call(env)
    end
  end
end
