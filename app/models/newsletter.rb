# == Schema Information
#
# Table name: newsletters
#
#  id                  :integer          not null, primary key
#  client_id           :integer          not null
#  name                :string(255)      not null
#  ecofax_number       :string(255)
#  ecofax_password     :string(255)
#  header_file_name    :string(255)
#  header_file_size    :integer
#  header_content_type :string(255)
#  header_updated_at   :datetime
#  header_fingerprint  :string(255)
#  introduction        :text
#  conclusion          :text
#  footer              :text
#  global_style        :text
#  print_style         :text
#  with_pdf            :boolean          default(FALSE), not null
#

class Newsletter < ActiveRecord::Base
  attr_accessible :client_id, :name, :ecofax_number, :ecofax_password, :header, :introduction, :conclusion, :footer, :global_style, :print_style, :with_pdf
  belongs_to :client, :class_name => "User"
  has_attached_file :header, {
    :styles => { :web => "720x2000>", :medium => "96x96#", :thumb => "48x48#" },
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }
  has_many :communications
  has_many :rubrics, :class_name => "NewsletterRubric"
  validates_presence_of :client



end
