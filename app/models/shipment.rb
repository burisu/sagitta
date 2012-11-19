# == Schema Information
#
# Table name: shipments
#
#  id               :integer          not null, primary key
#  communication_id :integer          not null
#  started_at       :datetime
#  stopped_at       :datetime
#  count            :integer          default(0), not null
#  total            :integer          default(0), not null
#  state            :string(255)      not null
#  report           :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Shipment < ActiveRecord::Base
  attr_accessible :description
  belongs_to :communication
  has_many :sendings
  has_many :touchables, :through => :sendings
  has_attached_file :mail, {
    
  }

  before_validation do
    self.state ||= "waiting"
  end



  def distribute
    # Start distribution
    self.update_attribute(:started_at, Time.now)
    self.update_attribute(:state, "sending")
    self.update_attribute(:dones, 0)
    # Email one-by-one
    self.sendings.where(:canal => "email").find_each do |sending|
      Distributor.communication(sending.touchable).deliver
      sending.update_attribute(:sent_at, Time.now)
      self.update_attribute(:dones, self.dones + 1)
    end
    
    # Fax all-in-one
    sendings = self.sendings.where(:canal => "fax")
    if sendings.count > 0
      Distributor.fax_shipment_request(self).deliver
      sendings.update_all({:sent_at => Time.now})
      self.update_attribute(:dones, self.dones + increment)
    end
    
    # Mail all-in-one
    if self.sendings.where(:canal => "mail").count > 0
      # Build each letter
      files = []
      self.sendings.where(:canal => "mail").find_each do |sending|
        file = Rails.root.join("tmp", "sending-#{sending.id}.pdf")
        files << file.to_s
        File.open(file, "wb") do |f|
          f.write self.communication.to_pdf(:mail => sending)
        end
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
      
    end

    
    self.update_attribute(:state, "done")
    self.update_attribute(:stopped_at, Time.now)

    return true
  end
  
  def progress
    return (100.to_f * self.dones.to_f / self.total.to_f).round(3)
  end

  def sending?
    self.state == "sending"
  end

end
