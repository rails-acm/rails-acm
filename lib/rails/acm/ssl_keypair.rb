# == Schema Information
#
# Table name: rails_acm_ssl_keypairs
#
#  id                          :bigint           not null, primary key
#  acme_identity_id            :bigint
#  encrypted_private_key       :string
#  encrypted_private_key_iv    :string
#  certificate_signing_request :string
#  certificate                 :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class Rails::Acm::SslKeypair < ActiveRecord::Base
  MAX_HOSTNAMES = 100 # Let's encrypt limitation
  REPLACMENT_THRESHOLD = 30.days # Let's encrypt suggestion

  include Rails::Acm::PrivateKeyMethods

  belongs_to :acme_identity
  has_many :domain_names
  has_one :heroku_ssl_endpoint

  def self.create_for_identity!(acme_identity:)
    create!(acme_identity: acme_identity,
      private_key: OpenSSL::PKey::RSA.new(4096))
  end

  def at_capacity?
    domain_names.size >= MAX_HOSTNAMES
  end

  def identifiers
    domain_names.map(&:hostname).sort
  end

  def expiring_soon?
    return false unless certificate.present?

    openssl_certificate.not_after <= Time.current + REPLACMENT_THRESHOLD
  end

  def openssl_certificate
    OpenSSL::X509::Certificate.new(certificate)
  end
end
