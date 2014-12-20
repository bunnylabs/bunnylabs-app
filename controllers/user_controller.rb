require_relative 'basic_controller.rb'

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

		@user = User.create :name => "kis",
							:email => "mail@mail.com", 
							:password => "myp455w0rd", 
							:validationToken => "content", 
							:registrationTime => DateTime.now
		"register"
	end

	#deregister
	delete '/:name' do
		"no more"
	end

	#validate
	get '/:name/validate/:validationToken' do
		validationToken = params[:validationToken]
	end

end
