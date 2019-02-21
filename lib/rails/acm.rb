require "rails/acm/version"

require "acme/client"
require "active_support"
require "active_support/core_ext"

module Rails
  module Acm
    mattr_accessor :encryption_key
    self.encryption_key = ENV["RAILS_ACM_ENCRYPTION_KEY"]

    mattr_accessor :job_queue
    self.job_queue = ""

    def self.table_name_prefix
      "rails_acm_"
    end

    class Error < StandardError; end

    class NoIdentifiersForKeypairError < Error; end

    class ChallengeValidationError < Error; end
  end
end

require "rails/acm/private_key_methods"
require "rails/acm/acme_challenge_middleware"
require "rails/acm/acme_identity"
require "rails/acm/callable"
require "rails/acm/domain_name"
require "rails/acm/heroku_ssl_endpoint"
require "rails/acm/http_challenge"
require "rails/acm/reissues_certificate"
require "rails/acm/reissue_certificate_job"
require "rails/acm/replaces_endpoint_certificate"
require "rails/acm/replace_certificate_job"
require "rails/acm/ssl_keypair"

require "rails/acm/engine"
