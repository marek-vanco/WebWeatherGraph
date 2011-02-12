#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'

KEY = '31cedb71bb220950113101'
FORMAT = 'json'
URLBASE = 'http://www.worldweatheronline.com'
DATA_DIR = "data/"

class Collector

  attr_accessor :locality, :url, :localtime
  attr_accessor :observation_time, :cloudcover, :humidity, :precip_mm, :presure, :temp_c, :temp_f, :visibility, :weather_code, :weather_desc, 
                :weather_icon_url, :winddir_16_point, :winddir_degree, :windspeed_kmph, :windspeed_miles 
  attr_accessor :date, :temp_max_c, :temp_max_f, :temp_min_c, :temp_min_f, :day_weather_code, :day_weather_desc, :day_weather_icon_url, 
                :day_winddir_16_point, :day_winddir_degree, :day_winddirection, :day_winspeed_kmph, :day_winspeed_miles

  def initialize(locality)
    @locality = locality
    @url = "#{URLBASE}/feed/weather.ashx?key = #{KEY}&q = #{locality}&format = #{FORMAT}&num_of_days = 2"
  end

  private
    # Define a correct filename from location name
    def normalize_filename(locality)
      return locality.gsub!(/[^0-9A-Za-z.\-]/, '_')
    end

    # Change time to standard rubytime
    def normalize_time
      hour = observation_time[0..1]
      minute = observation_time[3..4]
      ampm = observation_time[6]
      year = date[0..3]
      mounth = date[5..6]
      day = date[8..9]
      
      if ampm =  = 'P' 
        hour = @observation_time[0..1].to_i
        hour = hour+12
      end

      local_time = Time.now
      return Time.utc(year,mounth,day,hour,minute)
    end

    def normalize_weather_icon_url
      return weather_icon_url.split("/")[5] 
    end


  public
  def get_values
    rawdata = ''
    open(@url).each do |line|
      rawdata << line
    end

    data = JSON.parse(rawdata)
    @observation_time = data["data"]["current_condition"][0]["observation_time"]
    @cloudcover = data["data"]["current_condition"][0]["cloudcover"]
    @humidity = data["data"]["current_condition"][0]["humidity"]
    @precip_mm = data["data"]["current_condition"][0]["precipMM"]
    @presure = data["data"]["current_condition"][0]["pressure"]
    @temp_c = data["data"]["current_condition"][0]["temp_C"]
    @temp_f = data["data"]["current_condition"][0]["temp_F"]
    @visibility = data["data"]["current_condition"][0]["visibility"]
    @weather_code = data["data"]["current_condition"][0]["weatherCode"]
    @weather_desc = data["data"]["current_condition"][0]["weatehrDesc"]
    @weather_icon_url = data["data"]["current_condition"][0]["weatherIconUrl"][0]["value"]
    @winddir_16_point = data["data"]["current_condition"][0]["winddir16Point"]
    @winddir_degree = data["data"]["current_condition"][0]["winddirDegree"]
    @windspeed_kmph = data["data"]["current_condition"][0]["windspeedKmph"]
    @windspeed_miles = data["data"]["current_condition"][0]["windspeedMiles"]

    @date = data["data"]["weather"][0]["date"]
    @temp_max_c = data["data"]["weather"][0]["tempMaxC"]
    @temp_max_f = data["data"]["weather"][0]["tempMaxF"]
    @temp_min_c = data["data"]["weather"][0]["tempMinC"]
    @temp_min_f = data["data"]["weather"][0]["tempMinF"]
    @day_weather_code = data["data"]["weather"][0]["weatherCode"]
    @day_weather_desc = data["data"]["weather"][0]["weatherDesc"][0]["value"]
    @day_weather_icon_url = data["data"]["weather"][0]["weatherIconUrl"][0]["value"]
    @day_winddir_16_point = data["data"]["weather"][0]["winddir16Point"]
    @day_winddir_degree = data["data"]["weather"][0]["winddirDegree"]
    @day_winddirection = data["data"]["weather"][0]["windDirection"]
    @day_winspeed_kmph = data["data"]["weather"][0]["windspeedKmph"]
    @day_winspeed_miles = data["data"]["weather"][0]["windspeedMiles"]
    
    @observation_time = normalize_time
    @weather_icon_url = normalize_weather_icon_url
  end

  def save_values
    p dataline = "#{@observation_time}\t#{weather_code}\t#{temp_c}\t#{temp_f}\t#{humidity}\t#{presure}\t#{precip_mm}\t#{cloudcover}\t#{visibility}\t#{winddir_16_point}\t#{winddir_degree}\t#{windspeed_kmph}\t#{windspeed_miles}\t#{weather_icon_url}\n"
    f = File.new(DATA_DIR+normalize_filename(locality), "a+")
    f.write(dataline)
    f.close    
  end
end

class Weather
  attr_accessor :city, :country, :latitude, :longitude, :population, :weather_url

  def get_locality(locality)
    @url = "#{URLBASE}/feed/search.ashx?key = #{KEY}&q = #{locality}&format = #{FORMAT}&num_of_days = 2"

    rawdata = ''
    open(@url).each do |line|
      rawdata << line
    end
    p data = JSON.parse(rawdata)
    
    @city = data["search_api"]["result"][0]["areaName"][0]["value"]
    @country = data["search_api"]["result"][0]["country"][0]["value"]
    @latitude = data["search_api"]["result"][0]["latitude"]
    @longitude = data["search_api"]["result"][0]["longitude"]
    @population = data["search_api"]["result"][0]["population"]
    @weatherUrl = data["search_api"]["result"][0]["weatherUrl"][0]["value"]
  end  
end

Trencin = Collector.new("Trencin,Slovakia")
Trencin.get_values
Trencin.save_values
