class Untouchable < ActiveRecord::Base
  attr_accessible :email
  belongs_to :client, :class_name => "User"
  before_update :prevent_bad_update
  before_destroy :prevent_bad_update

  def prevent_bad_update
    old = self.class.find(self.id)
    return false unless old.destroyable?
  end
end
