# == Schema Information
#
# Table name: rails_acm_domain_names
#
#  id                      :bigint           not null, primary key
#  ssl_keypair_id          :bigint
#  hostname                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  route_53_hosted_zone_id :string
#

class Rails::Acm::DomainName < ActiveRecord::Base
  belongs_to :ssl_keypair
  has_many :http_challenges
end
