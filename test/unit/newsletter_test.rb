# == Schema Information
#
# Table name: newsletters
#
#  id                  :integer          not null, primary key
#  client_id           :integer
#  name                :string(255)
#  ecofax_number       :string(255)
#  ecofax_password     :string(255)
#  font_stack          :string(255)
#  header_file_name    :string(255)
#  header_file_size    :integer
#  header_content_type :string(255)
#  header_updated_at   :datetime
#  header_fingerprint  :string(255)
#  introduction        :text
#  conclusion          :text
#  footer              :text
#  global_style        :text
#

require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
