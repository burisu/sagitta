# == Schema Information
#
# Table name: newsletter_rubrics
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  name          :string(255)      not null
#  article_style :string(255)
#

require 'test_helper'

class NewsletterRubricTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
