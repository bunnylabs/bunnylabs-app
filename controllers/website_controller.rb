

class WebsiteController < ApplicationController
	
	get '/' do
	  "Art thou lost?"
	end

	get '/post' do
	  @user = User.create :username => "hello", :password => "content"

	  "Posted"
	end
end
