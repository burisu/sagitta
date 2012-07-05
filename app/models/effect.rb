class Effect < ActiveRecord::Base
  belongs_to :communication
  belongs_to :touchable
  # attr_accessible :title, :body
end
