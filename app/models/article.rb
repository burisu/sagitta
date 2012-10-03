# == Schema Information
#
# Table name: articles
#
#  id                :integer          not null, primary key
#  communication_id  :integer          not null
#  newsletter_id     :integer          not null
#  rubric_id         :integer
#  position          :integer
#  title             :string(255)
#  content           :text
#  readmore_url      :string(255)
#  readmore_label    :string(255)
#  logo_file_name    :string(255)
#  logo_file_size    :integer
#  logo_content_type :string(255)
#  logo_updated_at   :datetime
#  logo_fingerprint  :string(255)
#

class Article < ActiveRecord::Base
  attr_accessible :communication_id, :rubric_id, :title, :content, :readmore_url, :readmore_label, :position, :rubric_ids, :logo, :remove_logo
  belongs_to :communication
  belongs_to :newsletter
  belongs_to :rubric, :class_name => "NewsletterRubric"
  has_and_belongs_to_many :rubrics, :class_name => "NewsletterRubric"
  has_attached_file :logo, {
    :styles => { :inch => ["300x300>", :jpg], :web => ["128x128>", :jpg], :small => "96x96>", :thumb => "48x48" },
    :convert_options => { :inch => '-background white', :web => '-background white'}, #  -flatten +matte
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }
  acts_as_list :scope => :communication_id
  
  validates_presence_of :newsletter, :communication
  
  before_validation do
    self.readmore_label = "En savoir plus" if self.readmore_label.blank?
    if self.communication
      self.newsletter = self.communication.newsletter
    end
  end
  
  after_save do
    self.rubrics << self.rubric unless self.rubrics.include?(self.rubric)
  end

  def readmore_label
    self["readmore_label"] || "En savoir plus"
  end

  def remove_logo
    false
  end

  def remove_logo=(value)
    self.logo.destroy if value.to_i > 0 or value.is_a? TrueClass
  end

end
