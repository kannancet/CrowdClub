class ApplicationController < ActionController::Base
  #protect_from_forgery
=begin
  This defines functions to implement custom exception handling. 
=end  
      # rescue_from Exception, :with => :render_error
      # rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
      # rescue_from ActionController::RoutingError, :with => :render_not_found
      # rescue_from ActionController::UnknownController, :with => :render_not_found
      # rescue_from AbstractController::ActionNotFound, :with => :render_not_found
=begin
  This function implements the verification of authentication token for giving access to access controlled apis.
  The input auth token should match logged in user auth token, else the system will reject authorisation.
=end 
  def verify_authenticity_token
    authenticity_token = params[:auth_token] ||= request.headers["auth_token"]
    device_id = params[:device_id] ||= request.headers["device_id"]
    if authenticity_token.nil? or device_id.nil?
      render :status=>401,
             :json=>{:Message => "Auth Token and device id cannot be blank.",
                     :Response => "Fail"
                     }  
      return false
    end
    unless requested_user
       render :status=>200, :json=>{:Message=>"Unauthorized access.",
                            :Response => "Fail"}
    else
       return true
    end
  end

=begin
  This function implements the conversion to UTF-8
=end

  def to_utf8 untrusted_string=""
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    ic.iconv(untrusted_string + ' ')[0..-2]
  end  
  
=begin  config.consider_all_requests_local = false
  This function used to detect the current user. 
=end
  def requested_user
    authenticity_token = params[:auth_token] ||= request.headers["auth_token"]
    device_id = params[:device_id] ||= request.headers["device_id"]
    user = User.where(:authentication_token => authenticity_token, :device_id => device_id).first
    return user
  end

=begin
  This function is used for create a authentication token.
  Used for creating auth token on user creation.
=end   
  def ensure_authentication_token!
    reset_authentication_token! if authentication_token.blank?
  end

=begin
  This function is used for resetting the authentication token. 
=end  
  def reset_authentication_token
   self.authentication_token = self.class.authentication_token
  end

=begin
  This function is used to implement auth token expiration. 
=end  
  def expire_auth_token_on_timeout
    self.class.expire_auth_token_on_timeout
  end

  
=begin
  This implements custom exception handling. 
=end  
  def render_not_found(exception)
    render :status=>404,
           :json=>{:Message=>"Page not found",
                   :Response => "Fail",
                   :Data => exception.message}
  end
  
  def render_error(exception)
    render :status=>401,
           :json=>{:Message=>"OOps!!! Some thing went wrong.",
                   :Response => "Fail",
                   :Data => exception.message}
  end
  
  def no_route_found
    render :status=>404,
           :json=>{:Message=>"Invalid API URL.This API is not defined.",
                   :Response => "Fail",
                   :Data => nil}  
  end

end
