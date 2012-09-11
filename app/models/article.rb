class Article < ActiveRecord::Base
  attr_accessible :communication_id, :rubric_id, :title, :content, :link_url, :position
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
