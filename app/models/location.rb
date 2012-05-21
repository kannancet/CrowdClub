class Location < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :feeds
  validates_presence_of :latitude, :longitude
  validates :latitude, :uniqueness => {:scope => :longitude}
end
