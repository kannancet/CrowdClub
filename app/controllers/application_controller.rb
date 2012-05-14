class ApplicationController < ActionController::Base
  protect_from_forgery
=begin
  This function implements the verification of authentication token for giving access to access controlled apis.
  The input auth token should match logged in user auth token, else the system will reject authorisation.
=end 
  def verify_authenticity_token
      authenticity_token = params[:auth_token]
      if authenticity_token.nil?
        render :status=>401,
               :json=>{:Message => "Auth Token cannot be blank.",
                       :Response => "Fail"
                       }  
      end
      @user = User.where(:authentication_token => authenticity_token)
      if @user.blank?
         render :status=>200, :json=>{:Message=>"Unauthorized access.",
                              :Response => "Fail"}
         return false
      else
         return true
      end
  end
end
