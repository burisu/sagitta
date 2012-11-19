# == Schema Information
#
# Table name: touchables
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  sent_at          :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  key              :string(255)
#  test             :boolean          default(FALSE), not null
#  coordinate       :text
#  canal            :string(255)
#  search_key       :text
#

require 'test_helper'

class TouchableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
