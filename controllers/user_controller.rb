require_relative 'basic_controller.rb'

require 'pp'
require 'digest/sha1'
require 'net/smtp'

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

		request_payload["username"].downcase!
		#pp request_payload

		nameView = User.by_name.key(request_payload["username"])
		emailView = User.by_email.key(request_payload["email"])

		if nameView.rows.length != 0
			status 409
			return "User name " + request_payload["username"] + " already exists"
		end

		if emailView.rows.length != 0
			status 409
			return "E-mail " + request_payload["email"] + " already exists"
		end

		registrationTime = Time.now.to_i
		hashedPassword = Digest::SHA1.hexdigest request_payload["password"] + settings.salt
		hash = Digest::SHA1.hexdigest request_payload["username"] + registrationTime.to_s + request_payload["email"] + settings.salt

		user = User.create :name => request_payload["username"],
							:email => request_payload["email"],
							:password => hashedPassword,
							:validationToken => hash,
							:registrationTime => registrationTime,
							:accountType => "normal"

		return request_payload["username"]
	end

	#deregister
	delete '/:name' do
		"no more"
	end

	#validate
	get '/:name/validationToken/:validationToken' do
		name = params[:name]
		validationToken = params[:validationToken]

		nameView = User.by_name.limit(1)

		if nameView.total_rows == 0
			status 404
		end

		nameView.each do |user|
			user = User.get user.id
			if user[:validated]
				status 404
				return "Not found"
			end

			if user[:validationToken] == validationToken

				puts user.id
				user.update_attributes(:validated => true)
				return user[:name]
			else
				status 404
				return "Not found"
			end
		end
	end

	post '/:name/forgotPassword' do
		return "Info sent"
	end

end
