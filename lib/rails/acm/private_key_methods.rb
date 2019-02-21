module Rails::Acm
  module PrivateKeyMethods
    extend ActiveSupport::Concern

    included do
      attr_encrypted :private_key, key: proc{ Rails::Acm.encryption_key }
    end

    def rsa_key
      if private_key.is_a?(OpenSSL::PKey::RSA)
        private_key
      else
        OpenSSL::PKey::RSA.new(private_key)
      end
    end
  end
end
