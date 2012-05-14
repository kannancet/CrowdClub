class DashboardController < Devise::RegistrationsController

  attr_accessor :device_id, :latitude, longitude, :email, :status, :auth_token
  before_filter :verify_authenticity_token => , :only => [:update_user_credentials]
  before_filter :collect_parameters
  
=begin
  This function is used to initialize the user params. 
=end
  def collect_parameters
    @device_id = params[:device_id]
    @latitude = params[:latitude]
    @longitude = params[:longitude]  
    @email = params[:email]
    @status = params[:status]
    @auth_token = params[:auth_token]
  end

=begin
  Create Login for new or login for existing user
=end
  def index
    if device_id && latitude && longitude
      account_login_response, auth_token = parse_location_info_and_create_user_account
      render :status=>200,
             :json=>{:Message=>"Account created successfully for the user.",
                     :Response => "Success",
                     :Data => account_login_response,
                     :AuthToken => auth_token }
    else
      render :status=>401,
             :json=>{:Message=>"The request must contain the user device id, latitude and longitude.",
                     :Response => "Fail",
                     :Data => nil,
                     :AuthToken => nil}
    end
  end

=begin
  Get the user location using Google Geo Coding and create location if not exist
=end
  def parse_location_info_and_create_user_account
    location_id = google_reverse_coding(latitude,longitude)
    user = User.find_by_device_id(device_id)
    if user
      user.update_attributes(:latitude => latitude.to_f , :longitude => longitude.to_f, :location_id => location_id)
      user.save!
      return "Hi #{user.name}! Your location is updated.", user.authentication_token
    else
      user = User.new(:device_id => device_id,:latitude => latitude.to_f,:longitude => longitude.to_f, :location_id => location_id, :password => device_id)
      user.save!
      return "Welcome to CrowdClub! Please enter your email and status to continue.", user.authentication_token
    end
    user
  end

=begin
  Convert the latitude and longitude to corresponding address.
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
      location = Location.new(:street => street,:city => city,:state => state,:country => country, :latitude => latitude, :longitude => longitude)
      location.save!
      return location.id
    end
  end
  
=begin
  This function is used to update the user credentials like email and name. 
=end
  def update_user_credentials
    if auth_token 
      user = User.find_by_authentication_token(auth_token)
      user.update_attributes!(:email => email, :status => status, :name => name)
      render :status=>200,
             :json=>{:Message=>"Updated user credentials successfully.",
                     :Response => "Success",
                     :Data => "Hi, #{user.name}, your profile is up-to-date."}
    else
      render :status=>401,
             :json=>{:Message=>"The request must contain the user auth token.",
                     :Response => "Fail",
                     :Data => nil}
    end   
  end
end
