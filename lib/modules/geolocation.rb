module Geolocation
   module Finder
=begin
  Convert the latitude and longitude to corresponding address.
=end
    class Google
      def self.google_reverse_coding(user, latitude, longitude)
        result = Geocoder.search("#{latitude},#{longitude}")
        if result && result.first 
          geo_location = Hashie::Mash.new(:address => result.first.address,
                                          :city => result.first.city,
                                          :state => result.first.state,
                                          :country => result.first.country,
                                          :location => nil) 
          location = Location.find_by_latitude_and_longitude(latitude,longitude)
          user.locations.push(location = Location.create!(:address => geo_location.address,
                                                          :city => geo_location.city,
                                                          :state => geo_location.state,
                                                          :country => geo_location.country,
                                                          :latitude => latitude.to_f, 
                                                          :longitude => longitude.to_f,
                                                          :user_id => user.id)) if location.nil?
          user.locations.push(location) if user.locations.collect(&:id).include?(location.id)==false
          user.update_attributes!(:current_latitude => latitude.to_f,
                                  :current_longitude => longitude.to_f)
          geo_location.location = location
        end
        geo_location
      end
    end
   end
end