class DashboardController < Devise::RegistrationsController

  attr_accessor :device_id, :latitude, :longitude, :email, :status, :auth_token, :user_name, :user
  before_filter :collect_parameters
  
=begin
  This function is used to initialize the user params. 
=end
  def collect_parameters
    @device_id = params[:device_id]
    @email = params[:email]
    @latitude = params[:latitude]
    @longitude = params[:longitude]  
    @status = params[:status]
    @user_name = params[:user_name]
    @auth_token = params[:auth_token]
    @user
  end

=begin
  Create Login for new or login for existing user
=end
  def index
    begin
      if device_id && latitude && longitude
        account_login_response, auth_token = parse_location_info_and_create_user_account
        render :status=>200,
               :json=>{:Message=> account_login_response,
                       :Response => "Success",
                       :Data => account_login_response,
                       :AuthToken => auth_token }
      else
        render :status=>401,
               :json=>{:Message=>"The request must contain the user device id, latitude, longitude.",
                       :Response => "Fail",
                       :Data => nil,
                       :AuthToken => nil}
      end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Account creation failed.",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end

=begin
  Get the user location using Google Geo Coding and create location if not exist
=end
  def parse_location_info_and_create_user_account
    user = User.find_by_device_id(device_id)
    unless user
      user = User.create!(:device_id => device_id, 
                          :current_latitude => latitude.to_f, 
                          :current_longitude => longitude.to_f,
                          :password => email, 
                          :user_name => user_name,
                          :email => email, 
                          :status => status)
    else
      user.update_attributes!(:current_latitude => latitude.to_f,
                              :current_longitude => longitude.to_f)
    end
    user.ensure_authentication_token!
    geo_location_response = ::Geolocation::Finder::Google.google_reverse_coding(user, latitude, longitude)
    location_status = geo_location_response.nil? ? " Sorry! Unable to track location." : " Location tracked Successfully!"
    return "Hi #{user.user_name}, Welcome to CrowdClub.#{location_status}", user.authentication_token
  end

end
