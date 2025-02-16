class Api::SunriseSunsetController < ApplicationController
    require 'httparty'
    require 'dotenv'
    Dotenv.load
    
    def index
      location = params[:location]
      start_date = params[:start_date]
      end_date = params[:end_date]
      
      if location.blank? || start_date.blank? || end_date.blank?
        return render json: { error: 'Missing parameters' }, status: :bad_request
      end
      
      results = fetch_sunrise_sunset_data(location, start_date, end_date)
      render json: results
    end
    
    private

    def fetch_sunrise_sunset_data(location, start_date, end_date)
      coordinates = get_coordinates(location)
      return { error: coordinates[:error] } if coordinates[:error]
    
      location_lat = coordinates[:lat]
      location_lng = coordinates[:lng]
    
      final_list = []
      missing_dates = (Date.parse(start_date)..Date.parse(end_date)).to_a
    
      missing_dates.each do |date|
        existing_record = DailySunriseSunset.find_by(location: location, date: date)
        
        if existing_record
          final_list << existing_record
        else
          api_url = "https://api.sunrisesunset.io/json?lat=#{location_lat}&lng=#{location_lng}&date_start=#{date}&date_end=#{date}"
          response = HTTParty.get(api_url)
    
          if response.success?
            data = response.parsed_response["results"]
    
            record = DailySunriseSunset.create!(
              location: location,
              date: data[0]["date"],
              sunrise: data[0]["sunrise"],
              sunset: data[0]["sunset"],
              golden_hour: data[0]["golden_hour"]
            )
            
            final_list << record
          else
            return { error: 'Failed to fetch data from API' }
          end
        end
      end
    
      final_list
    end

    def get_coordinates(location)
      api_key = ENV['GEO_API_KEY']
      url = "https://api.opencagedata.com/geocode/v1/json?q=#{location}&key=#{api_key}"
    
      response = HTTParty.get(url)
      
      if response.success? && response.parsed_response['results'].any?
        lat = response.parsed_response['results'][0]['geometry']['lat']
        lng = response.parsed_response['results'][0]['geometry']['lng']
        { lat: lat, lng: lng }
      else
        { error: 'Failed to get coordinates for the location' }
      end
    end
  end