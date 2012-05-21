class Category < ActiveRecord::Base
  has_many :feeds
end
