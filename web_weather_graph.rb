require 'sinatra'
require 'open-uri'
require 'json'

DATA_DIR='data/'
URLBASE='http://www.worldweatheronline.com'
FORMAT='json'
KEY='31cedb71bb220950113101'


class WebWeatherGraph < Sinatra::Base
	set :static, true
	set :logging, true
	set :public, File.dirname(__FILE__)+'/static'

	get '/' do
		query='Trencin, Slovakia'
		Weather=WeatherData.new
		erb :index
	end

	post '/get_localities' do
		localities=Weather.get_localities(params[:query])
	end
end

class WeatherData

	attr_accessor :locality
	attr_accessor :observation_time, :cloudcover, :humidity, :precip_mm, :presure, :temp_c, :temp_f, :visibility, :weather_code, :weather_desc, 
								:weather_icon_url, :winddir_16_point, :winddir_degree, :windspeed_kmph, :windspeed_miles 

	private
	  # Define a correct filename from location name
		def normalize_locality(locality)
		  return locality.gsub!(/[^0-9A-Za-z.\-]/, ',')
		end

	public
		def initialize
			@observation_time=''
			@cloudcover=''
			@humidity=''
			@precip_mm=''
			@presure=''
			@temp_c=''
			@temp_f=''
			@visibility=''
			@weather_code=''
			@weather_desc=''
			@weather_icon_url=''
			@winddir_16_point=''
			@winddir_degree=''
			@windspeed_kmph=''
			@windspeed_miles=''
		end

		# Read all lines with last residual value
		def get_data(locality)
			File.open(DATA_DIR+locality,"r").each do |line|
				data=line.split("\t")

				@observation_time=data[0]
				@cloudcover=data[7]
				@humidity=data[4]
				@precip_mm=data[6]
				@presure=data[5]
				@temp_c=data[2]
				@temp_f=data[3]
				@visibility=data[8]
				@weather_code=data[1]
				@weather_desc=data
				@weather_icon_url=data[13][0..-2]
				@winddir_16_point=data[9]
				@winddir_degree=data[10]
				@windspeed_kmph=data[11]
				@windspeed_miles=data[12]
			end
			@locality=normalize_locality(locality)
		end

		def get_localities(query)
			@url="#{URLBASE}/feed/search.ashx?key=#{KEY}&q=#{query}&format=#{FORMAT}&num_of_days=2"

			rawdata=''
			open(@url).each do |line|
				rawdata << line
			end
			return data=JSON.parse(rawdata)
			
#			@city=data["search_api"]["result"][0]["areaName"][0]["value"]
#			@country=data["search_api"]["result"][0]["country"][0]["value"]
#			@latitude=data["search_api"]["result"][0]["latitude"]
#			@longitude=data["search_api"]["result"][0]["longitude"]
#			@population=data["search_api"]["result"][0]["population"]
#			@weatherUrl=data["search_api"]["result"][0]["weatherUrl"][0]["value"]
		end	 
end


# get '/named_via_params/:argument' do
#	"
#	Using: '/named_via_params/:argument'<br/>
#	params[:argument] -> #{params[:argument]} (Try changing it)
#	"
#end
#
# get '/named_via_block_parameter/:argument' do |argument|
#    "
#Using: '/named_via_block_parameter/:argument'<br/>
#argument -> #{argument}
#"
#  end
#
#  get '/splat/*/bar/*' do
#    "
#Using: '/splat/*/bar/*'<br/>
#params[:splat] -> #{params[:splat].join(', ')}
#"
#  end
#
#  get '/splat_extension/*.*' do
#    "
#Using: '/splat_extension/*.*'<br/>
#filename -> #{params[:splat][0]}<br/>
#extension -> #{params[:splat][1]}
#"
#  end
#
#  get %r{/regexp_params_captures/([\w]+)} do
#    "params[:captures].first -> '#{params[:captures].first}'"
#  end
#
#  get %r{/regexp_captures_via_block_parameter/([\w]+)} do |c|
#    "c -> '#{c}'"
#  end

