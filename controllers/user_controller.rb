require_relative 'basic_controller.rb'

require 'pp'
require 'digest/sha1'
require 'net/smtp'

class UserController < BasicController
	
	#register
	post '/' do

		request_payload = JSON.parse request.body.read

		if UserUtils.is_normal_username request_payload["username"] == false
			status 409
			return "Allowed usernames only contain letters, numbers and underscores"
		end

		result = UserUtils.create_user request_payload["username"], 
										request_payload["password"], 
										request_payload["email"], 
										"",
										settings.salt

		status result[:status]
		return result[:result]
	end

	#deregister
	delete '/:name' do
		"no more"
	end

	#validate
	get '/:name/validationToken/:validationToken' do
		name = params[:name]
		validationToken = params[:validationToken]

		user = UserUtils.get_user_named name

		if user == false or user[:validated] == true or user[:validationToken] != validationToken
			status 404
			return "Not found"
		end

		puts user.id
		user.update_attributes(:validated => true)
		return user[:name]
	end

	post '/:name/forgotPassword' do
		return "Info sent"
	end

end
