require_relative 'basic_controller.rb'

class PublicController < BasicController
	get '/health' do
		"OK"
	end
end
