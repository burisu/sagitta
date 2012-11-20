# == Schema Information
#
# Table name: sendings
#
#  id           :integer          not null, primary key
#  shipment_id  :integer          not null
#  touchable_id :integer
#  canal        :string(255)
#  coordinate   :text
#  sent_at      :datetime
#  report       :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Sending < ActiveRecord::Base
  attr_accessible :touchable
  belongs_to :sending
  belongs_to :touchable

  before_validation do
    if self.touchable
      self.canal = self.touchable.canal
      self.coordinate = self.touchable.coordinate
    end
  end
  
end
