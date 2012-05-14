class DashboardController < ApplicationController

  attr_accessor :device_id, :latitude, longitude
=begin
  This function is used to initialize the user params. 
=end
  def initialize
    @device_id = params[:device_id]
    @latitude = params[:latitude]
    @longitude = params[:longitude]   
  end

=begin
  Create Login for new or login for existing user
=end
  def index
    if device_id && latitude && longitude
      account_login_response = parse_location_info_and_create_user_account
      render :status=>200,
             :json=>{:Message=>"Successfully created the and accoubt for the user.",
                     :Response => "Success",
                     :Data => account_login_response}
    else
      render :status=>401,
             :json=>{:Message=>"The request must contain the user device id, latitude and longitude.",
                     :Response => "Fail",
                     :Data => nil}
    end
  end

=begin
  Get the user location using Google Geo Coding and create location if not exist
=end
  def parse_location_info_and_create_user_account
    location_id = google_reverse_coding(latitude,longitude)
    user = User.find_by_name(device_id_of_subscriber)
    if user
      user.update_attributes(:latitude => latitude.to_f , :longitude => longitude.to_f, :location_id => location_id)
      user.save!
      return "Welcome to your Crowd Club !!!\n\nUser name: #{@user.name}."
    else
      user = User.new(:name => device_id_of_subscriber,:latitude => latitude.to_f,:longitude => longitude.to_f, :location_id => location_id)
      user.save!
      return "An account is created for you !!!\n\nUser name: #{@user.name}."
    end
  end

=begin
  Convert the latitude and longitude to corresponding address
=end
  def google_reverse_coding(latitude,longitude)
    result = Geocoder.search("#{latitude},#{longitude}")
    street = result.first.address.split(",")[0]
    city = result.first.address.split(",")[1]
    state = result.first.address.split(",")[2]
    country = result.first.address.split(",")[3]
    location_find = Location.find_by_street(street)
    if location_find
      return location_find.id
    else
      location = Location.new(:street => street,:city => city,:state => state,:country => country)
      location.save!
      return location.id
    end
  end
end
