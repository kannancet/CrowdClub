require 'carrierwave/orm/activerecord'
class User < ActiveRecord::Base
  validates_presence_of :email, :device_id, :user_name
  validates_uniqueness_of :email, :device_id
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :token_authenticatable, :confirmable, 
         :lockable, :timeoutable
  has_and_belongs_to_many :locations
  #mount_uploader :image, AvatarUploader
  serialize :preferences
  
  
end
