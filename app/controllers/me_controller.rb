class MeController < ApplicationController

  attr_accessor :device_id, :auth_token, :status, 
                            :user_name, :latitude, 
                            :longitude, :comment, 
                            :category, :address,
                            :city, :state,
                            :country
  before_filter :verify_authenticity_token
  before_filter :collect_parameters
  
=begin
  This function is used to initialize the user params. 
=end
  def collect_parameters
    @device_id = params[:device_id]
    @auth_token = params[:auth_token]
    @status = params[:status]
    @user_name = params[:user_name]
    @latitude = params[:latitude]
    @longitude = params[:longitude]
    @comment = params[:comment]
    @category = params[:category]
    @address = params[:address]
    @city = params[:city]
    @state = params[:state]
    @country = params[:country]
  end

=begin
  This function is used retreive the user details from database. 
=end
  def get_user_data
    begin
      render :status=>200,
             :json=>{:Message=>"Successfully fetched user details of #{requested_user.user_name}",
                     :Response => "Success",
                     :Data => {:User => requested_user, :Locations => requested_user.locations}}
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while updating status",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end
  
=begin
  This function is used to download the image from  server 
=end
  def get_user_image
    begin
      if requested_user.image
        send_file(requested_user.image, 
                  :type => requested_user.image_content_type,
                  :filename => requested_user.image_name
                  ) 
      else 
        render :status=>401,
               :json=>{:Message=>"Sorry! you have not uploaded any image.",
                       :Response => "Fail",
                       :Data => nil}
      end  
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while adding new location.",
                     :Response => "Fail",
                     :Data => e.message}
    end 
  end
  
=begin
  This function is used to update the user credentials like email and name. 
=end
  def update_user_name_status
    begin
      if status & user_name
        requested_user.update_attributes!(:status => status, :user_name => user_name) 
        render :status=>200,
               :json=>{:Message=>"Updated user name and status successfully.",
                       :Response => "Success",
                       :Data => {:User => requested_user, :Locations => requested_user.locations}}
      else
        render :status=>401,
               :json=>{:Message=>"Request must contain user name and status.",
                       :Response => "Fail",
                       :Data => e.message}
      end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while updating status",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end

=begin
  This function is used to upload user image to server. 
=end  
  def update_user_image
    begin
      if request.body
        user_image_name = requested_user.user_name + "_#{requested_user.id}" + "." + request.content_mime_type.symbol.to_s
        serverpath = "#{Rails.root}/Data/user_image/#{user_image_name}"
        File.open(serverpath,"wb") do |file|
          file.write request.body.read
        end
      requested_user.update_attributes!(:image => serverpath, 
                                        :image_content_type => request.content_type,
                                        :image_name => user_image_name,
                                        :image_url => SERVER_DOMAIN_NAME + "crowdclub/api/get/user_image/" + user_image_name
                                        )
      render :status=>200,
             :json=>{:Message=>"Successfully uploaded user image.",
                     :Response => "Success",
                     :Data => requested_user.image_url}
    else
      render :status=>401,
             :json=>{:Message=>"Request must contain an image in the request body.",
                     :Response => "Fail",
                     :Data => e.message}      
    end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while uploading image",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end

=begin
  This function is user to add a location to the credit of user. 
=end

  def add_new_location
    begin
      if address && city && state && country && latitude & longitude
        requested_user.locations.push(Location.create!(:address => address,
                                                       :city => city,
                                                       :state => state,
                                                       :country => country,
                                                       :latitude => latitude.to_f, 
                                                       :longitude => longitude.to_f,
                                                       :user_id => requested_user.id))   
        requested_user.update_attributes!(:current_latitude => latitude.to_f,
                                          :current_longitude => longitude.to_f)                                    
        render :status=>200,
               :json=>{:Message=>"Successfully added new location to your credit.",
                       :Response => "Success",
                       :Data => {:User => requested_user, :Locations => requested_user.locations}}
      else
        render :status=>401,
               :json=>{:Message=>"The request must contain address, city, state country, latitude and longitude.",
                       :Response => "Fail",
                       :Data => nil}      
      end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while adding new location.",
                     :Response => "Fail",
                     :Data => e.message}
    end
  end
  
=begin
  This function is used to get user location 
=end
  def update_user_location
    begin
      if latitude && longitude
        geo_location_response = ::Geolocation::Finder::Google.google_reverse_coding(user, latitude, longitude)
        if geo_location_response
          render :status=>200,
                 :json=>{:Message=>"Successfully updated user location.",
                         :Response => "Success",
                         :Data => {:User => requested_user, :Locations => requested_user.locations}} 
        else
          render :status=>401,
                 :json=>{:Message=>"Hurray! You have explored a new location.Please add the location to your credit.",
                         :Response => "Fail",
                         :Data => nil}           
        end          
      else
        render :status=>401,
               :json=>{:Message=>"The request must contain latitude and longitude.",
                       :Response => "Fail",
                       :Data => nil}          
      end
    rescue Exception => e
      render :status=>401,
             :json=>{:Message=>"Error while adding new location.",
                     :Response => "Fail",
                     :Data => e.message}
    end 
  end 
  
end
