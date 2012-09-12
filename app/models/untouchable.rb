# == Schema Information
#
# Table name: untouchables
#
#  id              :integer          not null, primary key
#  client_id       :integer          not null
#  email           :string(255)      not null
#  destroyable     :boolean          default(FALSE), not null
#  unsubscribed_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# People who don't receive e-mails
class Untouchable < ActiveRecord::Base
  attr_accessible :email
  belongs_to :client, :class_name => "User"
  # before_update :prevent_bad_update
  # before_destroy :prevent_bad_update

  # def prevent_bad_update
  #   old = self.class.find(self.id)
  #   return false unless old.destroyable?
  # end
end
