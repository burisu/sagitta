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

require 'test_helper'

class EffectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
