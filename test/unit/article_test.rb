# == Schema Information
#
# Table name: articles
#
#  id               :integer          not null, primary key
#  communication_id :integer
#  newsletter_id    :integer
#  rubric_id        :integer
#  position         :integer
#  title            :string(255)
#  content          :text
#  link_url         :text
#

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
