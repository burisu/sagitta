# == Schema Information
#
# Table name: untouchables
#
#  id              :integer          not null, primary key
#  client_id       :integer          not null
#  destroyable     :boolean          default(FALSE), not null
#  unsubscribed_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  coordinate      :text
#  canal           :string(255)
#  search_key      :string(255)
#

# People who don't receive e-mails
class Untouchable < ActiveRecord::Base
  attr_accessible :canal, :coordinate
  belongs_to :client, :class_name => "User"
  # before_update :prevent_bad_update
  # before_destroy :prevent_bad_update

  default_scope order(:canal, :coordinate)

  # def prevent_bad_update
  #   old = self.class.find(self.id)
  #   return false unless old.destroyable?
  # end

  before_validation do
    self.search_key = self.canal + "/"
    if self.canal == "mail"
      self.search_key += self.coordinate.split(";").collect{|x| x.strip.parameterize}.join(";")
    else
      self.search_key += self.coordinate.strip.mb_chars.downcase
    end
    return true
  end
  
end
