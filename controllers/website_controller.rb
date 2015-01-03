require_relative 'authenticated_controller.rb'

class WebsiteController < AuthenticatedController
	
	get '/' do
	  "Hello world"
	end


	get '/userinfo' do
		halt 401
	end


	get '/post' do

	  "Posted"
	end
end
