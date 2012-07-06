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
  has_many :touchables, :dependent => :delete_all
  
  after_initialize do
    self.unreadable_label = "Cliquez-ici si le message est illisible"
    self.unsubscribe_label = "Se désabonner"
    self.message_label = "Consulter le message en ligne"
  end

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

  def from
    text = @communication.sender_email
    unless @communication.sender_label.blank?
      text = @communication.sender_label.gsub(/\</, '(').gsub(/\>/, ')')+" <" + text + ">"
    end
    return text
  end

end
