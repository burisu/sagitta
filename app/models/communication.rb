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
    self.unreadable_label ||= "Cliquez-ici si le message est illisible"
    self.unsubscribe_label ||= "Se désabonner"
    self.message_label ||= "Consulter le message en ligne"
  end

  before_validation do
    if self.key.blank?
      begin
        self.key = self.class.generate_key(43)
      end while self.class.find_by_key(self.key)
    end
  end

  def distribute_to(touchable)
    exception = []
    begin
      Distributor.news(touchable).deliver
    rescue Exception => e
      exception << e
    end
    return exception
  end

  def distribute(options = {})
    errors = []
    # self.touchables.where(options[:where]).where("email NOT IN (SELECT email FROM untouchables WHERE client_id=?)", self.client_id).find_each(:batch_size => 500) do |touchable|
    self.touchables.where(options[:where]).where("email NOT IN (SELECT email FROM untouchables)", self.client_id).find_each(:batch_size => 500) do |touchable|
      errors += self.distribute_to(touchable)
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

  def self.generate_key(key_length = 20)
    letters = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W Y X Z) #  0 1 2 3 4 5 6 7 8 9)
    letters_length = letters.length
    key = ''
    key_length.times do 
      key << letters[(letters_length*rand).to_i]
    end
    return key
  end

end
