class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :token_authenticatable, :confirmable, 
         :lockable, :timeoutable
  belongs_to :location
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :encrypted_password, :device_id, :name, :latitude, :longitude,
                  :preferences, :location_id, :status, :authentication_token
  serialize :preferences
end
