require_relative 'application_controller.rb'

class WebsiteController < ApplicationController
	
	get '/' do
	  "Art thou lost?"
	end


	get '/userinfo' do
		halt 401
	end


	get '/post' do

	  "Posted"
	end
end
