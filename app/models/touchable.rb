# == Schema Information
#
# Table name: touchables
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  sent_at          :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  key              :string(255)
#  test             :boolean          default(FALSE), not null
#  coordinate       :text
#  canal            :string(255)
#  search_key       :text
#

class Touchable < ActiveRecord::Base
  @@canals = ["email", "fax", "mail"]
  cattr_reader :canals
  belongs_to :communication
  has_many :effects
  attr_accessible :canal, :coordinate, :test
  validates_inclusion_of :canal, :in => @@canals
  validates_uniqueness_of :search_key, :scope => :communication_id

  before_validation do
    if self.key.blank?
      begin
        self.key = Communication.generate_key(64)
      end while self.class.find_by_key(self.key)
    end
    self.coordinate = self.coordinate.split(";").collect{|x| ActiveSupport::Inflector.transliterate(x.strip).upcase}.join(";") if self.canal == "mail"


    self.search_key = self.canal + "/"
    if self.canal == "mail"
      self.search_key += self.coordinate.split(";").collect{|x| x.strip.parameterize}.join(";")
    else
      self.search_key += self.coordinate.strip.mb_chars.downcase
    end
  end

  def stroke!
    self.communication.client.untouchables.create!(:email => self.email)
  end

end
