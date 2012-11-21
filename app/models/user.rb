# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  full_name              :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  authentication_token   :string(255)
#  administrator          :boolean
#  communications_quota   :integer          default(0), not null
#  communications_count   :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  costs                  :string(255)
#  canals_priority        :string(255)
#  ecofax_number          :string(255)
#  ecofax_password        :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :lockable, # :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :full_name, :administrator, :costs, :canals_priority, :ecofax_number, :ecofax_password
  
  has_many :communications, :foreign_key => :client_id, :dependent => :delete_all
  has_many :newsletters, :foreign_key => :client_id, :dependent => :delete_all, :order => :name
  has_many :untouchables, :foreign_key => :client_id, :dependent => :delete_all

  def name
    self.full_name
  end

  def costs_hash
    return self.costs.to_s.split(/\s*\n\s*/).collect{|l| l.split("=")}.inject({}) do |hash, pair|
      hash[pair[0].strip.downcase.to_s] = pair[1].strip.to_d
      hash
    end
  end

  def canals_priority_array
    array = self.canals_priority.to_s.strip.split(/\s*\,\s*/).collect{|x| x.strip.downcase}.delete_if{|x| !Touchable.canals.include?(x)}
    array = Touchable.canals if array.empty?
    return array
  end

end
