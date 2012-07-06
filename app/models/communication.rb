class Communication < ActiveRecord::Base
  attr_accessible :client_id, :name, :planned_on, :sender_email, :sender_label, :reply_to_email, :test_email, :message, :flyer
  belongs_to :client, :class_name => "User", :counter_cache => true
  has_attached_file :flyer, {
    :styles => { :web => "750x2000>", :medium => "96x96#", :thumb => "48x48#" },
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }
  has_many :effects, :dependent => :delete_all
  has_many :touchables, :dependent => :delete_all
  
  def test!
    Distributor.news(self.test_email, self).deliver
  end

  def distribute!
    self.touchables.find_each(:batch_size => 500) do |touchable|
      Distributor.news(touchable.email, self).deliver
      touchable.update_attribute!(:sent_at, Time.now)
    end
    self.distributed_at = Time.now
    self.distributed = true
    self.save!
  end

  def distributable?
    !self.distributed and self.touchables.count > 0
  end

end
