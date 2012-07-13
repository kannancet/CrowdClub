class BuddiesController < ApplicationController

  attr_accessor :search, :page, :origin_latitude, :origin_longitude, :proximity, :location_lock
  #before_filter :verify_authenticity_token
  before_filter :collect_parameters
  before_filter :validate_parameters , :only => [:search_buddies_by_location]
  
=begin
  This function is used to initialize the user params. 
=end
  def collect_parameters
    @search = params[:search]
    @page = (params[:page]).blank? ? 1 : params[:page]
    @latitude = params[:origin_latitude]
    @longitude = params[:origin_longitude]
    @location_lock = (params[:location_lock]).blank? ? "true" : params[:location_lock]
    @proximity = (params[:proximity]).blank? ? 5 : (params[:proximity]).to_i
    @user_id = params[:user_id]
  end
  
=begin
  This function is used to validate the parameters to the API. 
=end
  def validate_parameters
    if (latitude.to_f == 0.0) || (longitude.to_f == 0.0)
      render :status=>401,
             :json=>{:Message=>"The latitude and longitude parameters should be float values.",
                     :Response => "Fail",
                     :Data => nil} 
    end
    if (location_lock != "true") || (location_lock != "false")
      render :status=>401,
             :json=>{:Message=>"The location_lock should be either true or false.",
                     :Response => "Fail",
                     :Data => nil}       
    end
    if proximity.to_i == 0
      render :status=>401,
             :json=>{:Message=>"The proximity should be an integer.",
                     :Response => "Fail",
                     :Data => nil}     
    end
    if page.to_i == 0
      render :status=>401,
             :json=>{:Message=>"The page should be an integer.",
                     :Response => "Fail",
                     :Data => nil}         
    end
  end
  
=begin
  This function is used to  find the buddies nearby
=end
  def search_buddies_by_location
    buddy_data = []
    if latitude.blank? || longitude.blank?
      location = [requested_user.current_latitude, requested_user.current_longitude] 
    else
      location = [latitude.to_f, longitude.to_f]
    end
    if location_lock == "true"
      if search.blank?
        users = User.page(page).per(10).joins(:feeds).includes(:feeds).within(proximity, :origin => location)
      else
        users = User.page(page).per(10).joins(:feeds).includes(:feeds).where("name like '%#{search}%'").within(proximity, :origin => location)
      end
    else
      if search.blank?
        render :status=>401,
               :json=>{:Message=>"The search cannot be blank for universal search.",
                       :Response => "Fail",
                       :Data => nil}         
      end
      users = User.page(page).per(10).joins(:feeds).includes(:feeds).where("name like '%#{search}%'") unless search.blank?
    end
    users.collect {|user| buddy_data.push(Hashie::Mash.new(:User => user, :Feeds => user.feeds))}
    render :status=>200,
           :json=>{:Message=>"Here are the buddies near you!",
                   :Response => "Success",
                   :Data => buddy_data}      
  end
  
=begin
  This function is used to add friends to a user
=end
  def add_buddies_to_friends_list
    if user_id.blank?
      render :status=>401,
             :json=>{:Message=>"The user id cannot be blank for this api.",
                     :Response => "Fail",
                     :Data => nil}        
    end
    friend = User.find_by_id(user_id)
    friend.follow(requested_user)
    render :status=>200,
           :json=>{:Message=>"Added #{friend.name} to buddy list!",
                   :Response => "Success",
                   :Data => nil} 
  end
  
end
