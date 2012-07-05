class Touchable < ActiveRecord::Base
  belongs_to :communication
  has_many :effects
  attr_accessible :email
end
