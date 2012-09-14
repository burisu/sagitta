# == Schema Information
#
# Table name: articles
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  newsletter_id    :integer          not null
#  rubric_id        :integer
#  position         :integer
#  title            :string(255)
#  content          :text
#  readmore_url     :string(255)
#

require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
