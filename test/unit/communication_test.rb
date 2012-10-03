# == Schema Information
#
# Table name: communications
#
#  id                 :integer          not null, primary key
#  client_id          :integer          not null
#  name               :string(255)
#  planned_on         :date
#  sender_label       :string(255)
#  sender_email       :string(255)
#  reply_to_email     :string(255)
#  test_email         :string(255)
#  message            :text
#  flyer_file_name    :string(255)
#  flyer_file_size    :integer
#  flyer_content_type :string(255)
#  flyer_updated_at   :datetime
#  flyer_fingerprint  :string(255)
#  distributed        :boolean          default(FALSE), not null
#  distributed_at     :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  lock_version       :integer          default(0), not null
#  subject            :string(255)
#  unsubscribe_label  :string(255)
#  unreadable_label   :string(255)
#  message_label      :string(255)
#  target_url         :string(255)
#  key                :string(255)
#  introduction       :text
#  conclusion         :text
#  newsletter_id      :integer
#  title              :string(255)
#  with_pdf           :boolean          default(FALSE), not null
#

require 'test_helper'

class CommunicationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
