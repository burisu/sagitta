# == Schema Information
#
# Table name: newsletter_rubrics
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  name          :string(255)      not null
#  article_style :string(255)
#

class NewsletterRubric < ActiveRecord::Base
  attr_accessible :name, :article_style, :newsletter_id
  belongs_to :newsletter
  validates_presence_of :newsletter
end
