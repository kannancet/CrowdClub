class ApplicationController < ActionController::Base
  #protect_from_forgery
  
      rescue_from Exception, :with => :render_error
      rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
      rescue_from ActionController::RoutingError, :with => :render_not_found
      rescue_from ActionController::UnknownController, :with => :render_not_found
      rescue_from AbstractController::ActionNotFound, :with => :render_not_found
=begin
  This function implements the verification of authentication token for giving access to access controlled apis.
  The input auth token should match logged in user auth token, else the system will reject authorisation.
=end 
  def verify_authenticity_token
    authenticity_token = params[:auth_token]
    device_id = params[:device_id]
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
  
=begin  config.consider_all_requests_local = false
  This function used to detect the current user. 
=end
  def requested_user
    authenticity_token = params[:auth_token]
    device_id = params[:device_id]
    user = User.where(:authentication_token => authenticity_token, :device_id => device_id)
    return (user.blank? ? false : user)
  end
  
  
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
