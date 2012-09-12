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

class Article < ActiveRecord::Base
  attr_accessible :communication_id, :rubric_id, :title, :content, :readmore_url, :position
  belongs_to :communication
  belongs_to :newsletter
  belongs_to :rubric, :class_name => "NewsletterRubric"
  acts_as_list :scope => :communication_id
  
  validates_presence_of :newsletter, :communication
  
  before_validation do
    if self.communication
      self.newsletter = self.communication.newsletter
    end
  end

end
