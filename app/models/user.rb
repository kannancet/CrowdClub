require 'carrierwave/orm/activerecord'
class User < ActiveRecord::Base
  validates_presence_of :email, :device_id, :user_name
  validates_uniqueness_of :email, :device_id
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :token_authenticatable, :confirmable, 
         :lockable, :timeoutable
  has_and_belongs_to_many :locations
  has_many :feeds
  serialize :preferences
  serialize :image
  serialize :image_content_type
  serialize :image_name
  
end
