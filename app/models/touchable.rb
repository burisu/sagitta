# == Schema Information
#
# Table name: touchables
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  email            :string(255)      not null
#  sent_at          :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  key              :string(255)
#  test             :boolean          default(FALSE), not null
#  fax              :string(255)
#

class Touchable < ActiveRecord::Base
  belongs_to :communication
  has_many :effects
  attr_accessible :email, :test

  before_validation do
    if self.key.blank?
      begin
        self.key = Communication.generate_key(64)
      end while self.class.find_by_key(self.key)
    end
  end

  def stroke!
    self.communication.client.untouchables.create!(:email => self.email)
  end

end
