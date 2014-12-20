require_relative 'basic_controller.rb'

class SessionController < BasicController
	
	#get session info
	get '/' do
		"get session info"
	end

	#login
	post '/' do
		halt 403
	end

	#logout
	delete '/' do
	end

end
