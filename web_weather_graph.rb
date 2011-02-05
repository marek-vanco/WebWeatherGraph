require 'sinatra'

DATA_DIR='data/'

class WebWeatherGraph < Sinatra::Base
	set :static, true
	set :public, File.dirname(__FILE__)+'/static'

	get '/' do
		Trencin=WeatherData.new('Trencin_Slovakia')
		erb :index
	end
end

class WeatherData

	attr_accessor :observation_time, :cloudcover, :humidity, :precip_mm, :presure, :temp_c, :temp_f, :visibility, :weather_code, :weather_desc, 
								:weather_icon_url, :winddir_16_point, :winddir_degree, :windspeed_kmph, :windspeed_miles 

	def initialize(locality)
		  file=File.new(DATA_DIR+locality,"r")
			data=file.gets.split("\t")

			@observation_time=data[0]
			@cloudcover=data[7]
			@humidity=data[4]
			@precip_mm=data[6]
			@presure=data[5]
			@temp_c=data[2]
			@temp_f=data[3]
			@visibility=data[8]
			@weather_code=data[1]
	#		@weather_desc=data
			@weather_icon_url=data[13]
			@winddir_16_point=data[9]
			@winddir_degree=data[10]
			@windspeed_kmph=data[11]
			@windspeed_miles=data[12]
	file.close
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

