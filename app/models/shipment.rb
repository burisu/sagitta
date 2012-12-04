# == Schema Information
#
# Table name: shipments
#
#  id                :integer          not null, primary key
#  communication_id  :integer          not null
#  description       :string(255)
#  started_at        :datetime
#  stopped_at        :datetime
#  dones             :integer          default(0), not null
#  total             :integer          default(0), not null
#  state             :string(255)      not null
#  report            :text
#  mail_file_name    :string(255)
#  mail_file_size    :integer
#  mail_content_type :string(255)
#  mail_updated_at   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  launcher_id       :integer
#

class Shipment < ActiveRecord::Base
  attr_accessible :description
  belongs_to :communication
  belongs_to :launcher, :class_name => "User"
  has_many :sendings
  has_many :touchables, :through => :sendings
  has_attached_file :mail, {
    :url  => "/admin/shipments/:id/mail/:style.:extension",
    :path => ":rails_root/private/:class/:id_partition/:attachment/:style.:extension"
  }

  before_validation do
    self.state ||= "waiting"
  end

  def distribute
    # Start distribution
    self.update_attribute(:started_at, Time.now)
    self.update_attribute(:state, "sending")
    self.update_attribute(:dones, 0)

    # Mail all-in-one
    if self.sendings.where(:canal => "mail").count > 0
      # Build each letter
      files = []
      self.sendings.where(:canal => "mail").find_each do |sending|
        file = Rails.root.join("tmp", "sending-#{sending.id}.pdf")
        files << file.to_s
        self.communication.mail_to(sending, :output => file)
        sending.update_attribute(:sent_at, Time.now)
        self.update_attribute(:dones, self.dones + 1)
      end
      # Merge all letters
      output = Rails.root.join("tmp", "shipment-#{self.id}.pdf")
      system("pdftk #{files.join(' ')} cat output #{output}")

      # Register PDF in mail
      File.open(output, "rb") do |f|
        self.mail = f
        self.save
      end
      # Send mail to give link to download
      # TODO: Notify user that it's finished
    end

    # Fax all-in-one
    sendings = self.sendings.where(:canal => "fax")
    if sendings.count > 0
      Distributor.fax_shipment_request(self).deliver
      sendings.update_all({:sent_at => Time.now})
      self.update_attribute(:dones, self.dones + sendings.count)
    end
    
    # Email one-by-one
    self.sendings.where(:canal => "email").find_each do |sending|
      Distributor.communication(sending.touchable).deliver
      sending.update_attribute(:sent_at, Time.now)
      self.update_attribute(:dones, self.dones + 1)
    end
    
    self.update_attribute(:state, "done")
    self.update_attribute(:stopped_at, Time.now)

    return true
  end
  
  def progress
    return (100.to_f * self.dones.to_f / self.total.to_f).round(3)
  end

  def done?
    self.state == "done"
  end

  def sending?
    self.state == "sending"
  end

end
