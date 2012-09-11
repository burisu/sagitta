class Newsletter < ActiveRecord::Base
  attr_accessible :client_id, :name, :ecofax_number, :ecofax_password, :font_stack, :header, :header_text_position, :header_text_style, :introduction, :conclusion, :footer, :titles_style, :styles
  belongs_to :client, :class_name => "User"
  has_attached_file :header
  has_many :communications
  has_many :rubrics, :class_name => "NewsletterRubric"
  validates_presence_of :client

end
