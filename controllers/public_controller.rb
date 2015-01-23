require_relative 'basic_controller.rb'

# This controller is for the public to use
class PublicController < BasicController
	get '/health' do
		"OK"
	end
end
