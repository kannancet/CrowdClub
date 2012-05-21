class FeedsController < ApplicationController

  attr_accessor :latitude, :longitude, :comment, :category
  before_filter :verify_authenticity_token
  before_filter :collect_parameters
  
=begin
  This function is used to initialize the user params. 
=end
  def collect_parameters
    @latitude = request.headers["latitude"]
    @longitude = request.headers["longitude"]
    @comment = request.headers["comment"]
    @category = request.headers["category"]
  end
  
=begin
  This function is used to implement the creation  of feeds by the user.
=end
  def create_user_feed
    begin
      if comment && category && latitude && longitude
        geolocation_response = ::Geolocation::Finder::Google.google_reverse_coding(requested_user, latitude, longitude) if latitude &longitude
        if geolocation_response
          Feed.create!(:category_id => Category.find_by_name(category).id,
                       :user_id => requested_user.id,
                       :comment => comment,
                       :image => request.body.read,
                       :location_id => geolocation_response.location.id)
          render :status=>200,
                 :json=>{:Message=>"Successfully created a feed about #{geolocation_response.location.address}",
                         :Response => "Success",
                         :Data => "Successfully created a feed about #{geolocation_response.location.address}"}
        else
          render :status=>401,
                 :json=>{:Message=>"Hurray! You have explored a new location.Please add the location to your credit.",
                         :Response => "Fail",
                         :Data => nil}        
        end 
      else
        render :status=>401,
               :json=>{:Message=>"The request must contain comment, category, latitude, longitude.",
                       :Response => "Fail",
                       :Data => nil} 
      end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while creating feed.",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end
  
=begin
  This function is used to get the feeds the user have created. 
=end
  def get_user_feed
    begin
      if category 
        page = page ? page : "1"
        category_found = Category.find_by_name(category)
        condition = "user_id=#{requested_user.id}"
        condition = "category_id=#{category_found.id} and user_id=#{requested_user.id}" if category_found
        feeds = Feed.page(page.to_i).per(10).joins(:categories).includes(:categories).where(condition) 
        render :status=>200,
               :json=>{:Message=>"Successfully fetched the feeds.",
                       :Response => "Success",
                       :Data => {:Feeds => feeds, :Categories => feeds.collect(&:category).uniq}}
      else
        render :status=>401,
               :json=>{:Message=>"Request must contain category name eg.Traffic or All to get category feeds.",
                       :Response => "Fail",
                       :Data => e.message}
      end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while fetching feeds.",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end
  
=begin
  This function is used to fetch the category list 
=end
  def get_category_list
    begin
      render :status=>200,
             :json=>{:Message=>"Successfully fetched the categories.",
                     :Response => "Success",
                     :Data => {:Categories => Category.all.order("category_id DESC")}}
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while fetching categories.",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end
end
