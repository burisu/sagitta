# == Schema Information
#
# Table name: effects
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  sending_id       :integer
#  nature           :string(255)      not null
#  made_at          :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  shipment_id      :integer
#

# Returns from touched people (Clicks or visits)
class Effect < ActiveRecord::Base
  attr_accessible :nature
  belongs_to :communication
  belongs_to :shipment
  belongs_to :sending
  extend Enumerize
  enumerize :nature, :in => [:opening, :target_click, :page_click, :unsubscribe]
  validates_presence_of :sending, :shipment, :communication

  before_validation :on => :create do
    self.made_at = Time.now
  end

  before_validation do
    self.shipment_id = self.sending.shipment_id if self.sending
    self.communication_id = self.shipment.communication_id if self.shipment
  end

end
