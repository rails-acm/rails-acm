# == Schema Information
#
# Table name: rails_acm_http_challenges
#
#  id             :bigint           not null, primary key
#  domain_name_id :bigint
#  filename       :string
#  file_content   :string
#  token          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Rails::Acm::HttpChallenge < ActiveRecord::Base
  belongs_to :domain_name
end
