# == Schema Information
#
# Table name: untouchables
#
#  id              :integer          not null, primary key
#  client_id       :integer          not null
#  email           :string(255)      not null
#  destroyable     :boolean          default(FALSE), not null
#  unsubscribed_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class UntouchableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
