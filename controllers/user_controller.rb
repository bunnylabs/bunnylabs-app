require_relative 'basic_controller.rb'
require "pp"

class UserController < BasicController
	
	#check if user exists
	get '/:name' do
		view = User.by_name.key(params[:name])

		if view.rows.length == 0 
			halt 404
		end

		params[:name]
	end

	#register
	post '/' do

		request_payload = JSON.parse request.body.read

		pp request_payload

		#@user = User.create :name => "kis",
		#					:email => "mail@mail.com", 
		#					:password => "myp455w0rd", 
		#					:validationToken => "content", 
		#					:registrationTime => DateTime.now
		"register"
	end

	#deregister
	delete '/:name' do
		"no more"
	end

	#validate
	post '/:name/validationToken/:validationToken' do
		validationToken = params[:validationToken]
	end

end
