# == Schema Information
#
# Table name: effects
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  touchable_id     :integer
#  nature           :string(255)      not null
#  made_at          :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

# Returns from touched people (Clicks or visits)
class Effect < ActiveRecord::Base
  belongs_to :communication
  belongs_to :touchable
  # attr_accessible :title, :body
end
