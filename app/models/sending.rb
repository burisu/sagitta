# == Schema Information
#
# Table name: sendings
#
#  id               :integer          not null, primary key
#  shipment_id      :integer          not null
#  touchable_id     :integer
#  canal            :string(255)
#  coordinate       :text
#  sent_at          :datetime
#  report           :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  key              :string(255)
#  communication_id :integer
#

class Sending < ActiveRecord::Base
  attr_accessible :touchable
  belongs_to :communication, :inverse_of => :sendings
  belongs_to :shipment, :inverse_of => :sendings
  belongs_to :touchable
  has_many :effects
  for nature in Effect.nature.values
    has_many "#{nature}_effects", :class_name => "Effect", :conditions => {:nature => nature}
  end

  before_validation do
    if self.touchable
      self.canal = self.touchable.canal
      self.coordinate = self.touchable.coordinate
    end
    self.communication_id = self.shipment.communication_id if self.shipment
    if self.key.blank?
      begin
        self.key = self.class.generate_key(32)
      end while self.class.find_by_key(self.key)
    end
  end

  # Add effect
  def add(nature)
    self.effects.create!(:nature => nature)
  end
  

  def self.generate_key(key_length = 20)
    letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W Y X Z 0 1 2 3 4 5 6 7 8 9)
    letters_length = letters.length
    key = ''
    key_length.times do 
      key << letters[(letters_length*rand).to_i]
    end
    return key
  end

end
