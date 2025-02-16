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
  
    def fetch_sunrise_sunset_data1(location, start_date, end_date)
      existing_data = DailySunriseSunset.where(location: location, date: start_date..end_date)
      
      coordinates = get_coordinates(location)

      if coordinates[:error]
        return { error: coordinates[:error] }
      end
      
      locationLat = coordinates[:lat]
      locationLng = coordinates[:lng]

      if existing_data.any?
        return existing_data
      end
      
      url = "https://api.sunrisesunset.io/json?lat=#{locationLat}&lng=#{locationLng}&date_start=#{start_date}&date_end=#{end_date}"
      response = HTTParty.get(url)

      if response.success?
        data = response.parsed_response["results"]

        start_date_toDate = Date.parse(start_date)
        end_date_toDate = Date.parse(end_date)

        number_of_days = (end_date_toDate - start_date_toDate).to_i + 1

        for elem in data do
          sunrise_time = Time.parse(elem["sunrise"]).to_s
          sunset_time = Time.parse(elem["sunset"]).to_s
          golden_hour_time = Time.parse(elem["golden_hour"]).to_s


          DailySunriseSunset.create(
            location: location,
            date: elem["date"],
            sunrise: sunrise_time,
            sunset: sunset_time,
            golden_hour: golden_hour_time
          )
        end
      else
        { error: 'Failed to fetch data' }
      end
    end

    def fetch_sunrise_sunset_data(location, start_date, end_date)
      coordinates = get_coordinates(location)
      return { error: coordinates[:error] } if coordinates[:error]
    
      location_lat = coordinates[:lat]
      location_lng = coordinates[:lng]
    
      # Convert dates to an array of all days in the range
      missing_dates = (Date.parse(start_date)..Date.parse(end_date)).to_a
    
      # Check which dates are already in the database
      existing_records = DailySunriseSunset.where(location: location, date: missing_dates).pluck(:date)
      missing_dates -= existing_records  # Remove dates that already exist
    
      # If all dates exist, return the stored data
      if missing_dates.empty?
        return DailySunriseSunset.where(location: location, date: start_date..end_date)
      end
    
      # Fetch only missing dates from API
      missing_dates_str = missing_dates.map(&:to_s).join(",") # Format for API request
      api_url = "https://api.sunrisesunset.io/json?lat=#{location_lat}&lng=#{location_lng}&date_start=#{start_date}&date_end=#{end_date}"
      response = HTTParty.get(api_url)
    
      if response.success?
        data = response.parsed_response["results"]
    
        # Store fetched data in DB
        data.each do |elem|
          DailySunriseSunset.create!(
            location: location,
            date: elem["date"],
            sunrise: elem["sunrise"],
            sunset: elem["sunset"],
            golden_hour: elem["golden_hour"]
          )
        end
      else
        return { error: 'Failed to fetch data from API' }
      end
    
      # Return the full dataset (both from DB and newly fetched)
      DailySunriseSunset.where(location: location, date: start_date..end_date)
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