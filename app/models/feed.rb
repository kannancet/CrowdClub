class Feed < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  belongs_to :location
  serialize :image
end
