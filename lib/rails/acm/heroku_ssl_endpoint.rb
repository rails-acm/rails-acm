# == Schema Information
#
# Table name: rails_acm_heroku_ssl_endpoints
#
#  id             :bigint           not null, primary key
#  ssl_keypair_id :bigint
#  heroku_id      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Rails::Acm::HerokuSslEndpoint < ActiveRecord::Base
  belongs_to :ssl_keypair

  enum :endpoint_type, [:ssl_endpoint, :sni_endpoint]

  def expiring_soon?
    ssl_keypair.expiring_soon?
  end
end
