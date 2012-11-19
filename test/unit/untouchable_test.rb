# == Schema Information
#
# Table name: untouchables
#
#  id              :integer          not null, primary key
#  client_id       :integer          not null
#  destroyable     :boolean          default(FALSE), not null
#  unsubscribed_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  coordinate      :text
#  canal           :string(255)
#  search_key      :string(255)
#

require 'test_helper'

class UntouchableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
