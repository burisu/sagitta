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

class NewsletterRubric < ActiveRecord::Base
  attr_accessible :name, :article_style, :newsletter_id
  belongs_to :newsletter
  validates_presence_of :newsletter
end
