# == Schema Information
#
# Table name: rails_acm_acme_identities
#
#  id                       :bigint           not null, primary key
#  encrypted_private_key    :string
#  encrypted_private_key_iv :string
#  email                    :string
#  key_identifier           :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Rails::Acm::AcmeIdentity < ActiveRecord::Base
  include Rails::Acm::PrivateKeyMethods

  PRODUCTION_DIRECTORY = "https://acme-v02.api.letsencrypt.org/directory".freeze

  has_many :ssl_keypairs

  def self.create_with_account!(email:, directory: PRODUCTION_DIRECTORY)
    private_key = OpenSSL::PKey::RSA.new(4096)
    client = Acme::Client.new(private_key: private_key, directory: directory)
    account = client.new_account(contact: "mailto:#{email}", terms_of_service_agreed: true)
    create!(email: email, private_key: private_key, key_identifier: account.kid)
  end

  def acme_client(directory: PRODUCTION_DIRECTORY)
    Acme::Client.new(private_key: rsa_key, directory: directory, kid: key_identifier)
  end
end
