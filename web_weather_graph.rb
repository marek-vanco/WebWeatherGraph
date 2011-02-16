require 'sinatra'
require 'open-uri'
require 'json'
require 'erb'
require 'parseconfig'
require 'yaml'
require 'cgi'

config = ParseConfig.new('./web_weather_graph.conf')
KEY = config.params['datasource']['key']
DATA_DIR = config.params['weather_graph']['datadir']
COLLECTOR_CONF =  config.params['weather_graph']['collector_file']

URLBASE = 'http://www.worldweatheronline.com'
FORMAT = 'json'

class WeatherData
  attr_accessor :locality
  attr_accessor :observation_time, :cloudcover, :humidity, :precip_mm, :presure, :temp_c, :temp_f, :visibility, :weather_code, :weather_desc, 
                :weather_icon_url, :winddir_16_point, :winddir_degree, :windspeed_kmph, :windspeed_miles 

  private
    # Define a correct filename from location name
    def normalize_locality(locality)
      return locality.gsub!(/[^0-9A-Za-z.\-]/, '_')
    end

  public
    def initialize
      @observation_time = ''
      @cloudcover = ''
      @humidity = ''
      @precip_mm = ''
      @presure = ''
      @temp_c = ''
      @temp_f = ''
      @visibility = ''
      @weather_code = ''
      @weather_desc = ''
      @weather_icon_url = ''
      @winddir_16_point = ''
      @winddir_degree = ''
      @windspeed_kmph = ''
      @windspeed_miles = ''
    end

    # Read all lines with last residual value
    def get_data(locality)
      File.open(DATA_DIR+normalize_locality(locality),"r").each do |line|
        data = line.split("\t")

        @observation_time = data[0]
        @cloudcover = data[7]
        @humidity = data[4]
        @precip_mm = data[6]
        @presure = data[5]
        @temp_c = data[2]
        @temp_f = data[3]
        @visibility = data[8]
        @weather_code = data[1]
        @weather_desc = data
        @weather_icon_url = data[13][0..-2]
        @winddir_16_point = data[9]
        @winddir_degree = data[10]
        @windspeed_kmph = data[11]
        @windspeed_miles = data[12]
      end
      @locality = normalize_locality(locality)
    end

    # return hash of localities matches with query
    def get_localities(query)
      p query_escaped = CGI::escape(query)
      @url = "#{URLBASE}/feed/search.ashx?key=#{KEY}&q=#{query_escaped}&format=#{FORMAT}&num_of_days=2"

      rawdata = ''
      open(@url).each do |line|
        rawdata << line
      end
      data = JSON.parse(rawdata)
      return data["search_api"]["result"]
      
#      @city = data[0]["areaName"][0]["value"]
#      @country = data[0]["country"][0]["value"]
#      @latitude = data[0]["latitude"]
#      @longitude = data[0]["longitude"]
#      @population = data[0]["population"]
#      @weatherUrl = data[0]["weatherUrl"][0]["value"]
    end   

    # Add locality to COLLECTOR_FILE for collector script
    def add_to_collector(locality)
      p locality.to_yaml
#      open(DATA_DIR+COLLECTOR_CONF,'w') {|f| YAML.dump(locality, f)}
    end
end

class WebWeatherGraph < Sinatra::Base
  set :static, true
  set :logging, true
  set :public, File.dirname(__FILE__) + '/static'
  set :views, File.dirname(__FILE__) + '/views'

# Need I do this? -> I don't know... (to not create a new instance for all time)
  before do
    unless defined? @weather
      @weather = WeatherData.new
    end
  end

  get '/' do  
#     if params[:locality] == nil 
#        locality = "Trencin,Slovakia" 
#      else
       p  locality = params[:locality]
       locality=nil 
       params[:locality]=nil

#      end
#      p locality
#      @weather.get_data(locality)
#     @weather.add_to_collector(locality)

    erb :index
  end

  post '/get_localities' do
    @localities = @weather.get_localities(params[:query])
    erb :get_localities
  end

  post 'select_locality' do
    p locality = params[:locality]
  end
end
