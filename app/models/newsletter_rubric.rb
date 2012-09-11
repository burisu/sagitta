class NewsletterRubric < ActiveRecord::Base
  attr_accessible :name, :border, :color, :newsletter_id
  belongs_to :newsletter
  validates_presence_of :newsletter
end
