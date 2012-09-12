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

require 'test_helper'

class TouchableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
