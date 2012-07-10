# -*- coding: utf-8 -*-
class Communication < ActiveRecord::Base
  attr_accessible :client_id, :name, :planned_on, :sender_email, :sender_label, :reply_to_email, :test_email, :message, :flyer, :unreadable_label, :unsubscribe_label, :message_label, :subject, :target_url
  belongs_to :client, :class_name => "User", :counter_cache => true
  has_attached_file :flyer, {
    :styles => { :web => "640x2000>", :medium => "96x96#", :thumb => "48x48#" },
    :path => ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename",
    :url => "/system/:class/:attachment/:id_partition/:style/:filename"
  }
  has_many :effects, :dependent => :delete_all
  has_many :touchables, :dependent => :delete_all, :order => :email
  
  after_initialize do
    self.unreadable_label = "Cliquez-ici si le message est illisible"
    self.unsubscribe_label = "Se désabonner"
    self.message_label = "Consulter le message en ligne"
  end

  def distribute_to!(email)
    Distributor.news(email, self).deliver
  end

  def distribute_to(email = nil)
    email ||= self.test_email
    exception = []
    begin
      self.distribute_to!(email)
    rescue Exception => e
      exception << e
    end
    return exception
  end

  def distribute(options = {})
    errors = []
    self.touchables.where(options[:where]).where("email NOT IN (SELECT email FROM untouchables WHERE client_id=?)", self.client_id).find_each(:batch_size => 500) do |touchable|
      errors += self.distribute_to(touchable.email)
      touchable.update_attribute(:sent_at, Time.now)
    end
    # self.distributed_at = Time.now
    # self.distributed = true
    self.save
    return errors
  end

  def distributable?
    !self.distributed and self.touchables.count > 0
  end

  def from
    text = self.sender_email
    unless self.sender_label.blank?
      text = self.sender_label.gsub(/\</, '(').gsub(/\>/, ')')+" <" + text + ">"
    end
    return text
  end

end
