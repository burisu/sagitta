# == Schema Information
#
# Table name: pieces
#
#  id                    :integer          not null, primary key
#  communication_id      :integer          not null
#  article_id            :integer
#  name                  :string(255)
#  document_file_name    :string(255)
#  document_file_size    :integer
#  document_content_type :string(255)
#  document_updated_at   :datetime
#  document_fingerprint  :string(255)
#

class Piece < ActiveRecord::Base
  attr_accessible :communication_id, :article_id, :name, :document
  belongs_to :article
  belongs_to :communication
  has_attached_file :document, {
    :path => ":rails_root/private/:class/:attachment/:id_partition/:style/:filename",
    :url => "/:class/:id.pdf"
  }
  validates_attachment_presence :document
  # validates_attachment_content_type :document, :content_type => [ 'application/pdf', 'application/x-pdf' ]
  # validates_attachment_size :document, :less_than => 20.megabytes
  validates_uniqueness_of :name, :scope => :communication_id

  before_validation do
    self.communication = self.article.communication if self.article
  end

end
