# == Schema Information
#
# Table name: newsletter_rubrics
#
#  id                  :integer          not null, primary key
#  newsletter_id       :integer          not null
#  name                :string(255)      not null
#  article_style       :text
#  article_print_style :text
#

require 'test_helper'

class NewsletterRubricTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
