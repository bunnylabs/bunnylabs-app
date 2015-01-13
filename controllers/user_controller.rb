require_relative 'basic_controller.rb'

require 'pp'
require 'digest/sha1'
require 'net/smtp'
require 'pony'

class UserController < BasicController
	
	#register
	post '/' do

		if settings.basic_registration_enabled == false
			status 403
			return "Registration has been disabled"
		end

		request_payload = JSON.parse request.body.read

		if (UserUtils.is_normal_username request_payload["username"]) == false
			status 409
			return "Allowed usernames only contain letters, numbers and underscores"
		end

		result = UserUtils.create_user request_payload["username"], 
										request_payload["password"], 
										request_payload["email"], 
										"",
										settings.salt

		if result[:status] == 200

			user = UserUtils.get_user_named request_payload["username"]

			message = <<-MESSAGE_END
Hello, #{request_payload["username"]}

This e-mail is sent to you because you registered an account using this e-mail address on BunnyLabs.

If you do not believe that you registered an account, please feel free to ignore this mail or throw it in the trash.

Otherwise please click the following link to complete your registration:

#{settings.front_end_address}/en/#validate=#{user[:validationToken]}&validateUsername=#{user[:name]}

Astrobunny
			MESSAGE_END

			Pony.mail({
				:to => request_payload["email"],
				:from => 'no-reply@astrobunny.net', 
				:subject => 'Welcome to BunnyLabs!', 
				:body => message,
				:via => :smtp,
				:via_options => {
					:address              => 'smtp.gmail.com',
					:port                 => '587',
					:enable_starttls_auto => true,
					:user_name            => ENV['MAIL_USERNAME'],
					:password             => ENV['MAIL_PASSWORD'],
					:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
					:domain               => "astrobunny.net" # the HELO domain provided by the client to the server
				}
			})
		end


		status result[:status]
		return result[:result]
	end

	#deregister
	delete '/:name' do
		"no more"
	end

	#validate
	post '/:name/validation' do

		request_payload = JSON.parse request.body.read

		name = request_payload["name"]
		validationToken = request_payload["validationToken"]

		user = UserUtils.get_user_named name

		if params[:name] != request_payload["name"] or 
			user == false or 
			user[:validated] == true or 
			user[:validationToken] != validationToken

			status 404
			return "Not found"
		end

		user.update_attributes(:validated => true)

		# Change the validation token
		currentTime = Time.now.to_i
		hash = Digest::SHA1.hexdigest user[:name] + currentTime.to_s + user[:email] + settings.salt
		user.update_attributes(:validationToken => hash)

		return user[:name]
	end

	# change password
	post '/:name/password' do

		request_payload = JSON.parse request.body.read

		name = request_payload["name"]
		password = request_payload["password"]
		validationToken = request_payload["validationToken"]

		user = UserUtils.get_user_named name

		if user == false or user[:validationToken] != validationToken or params[:name] != name
			status 404
			return "Not found"
		end

		hashedPassword = Digest::SHA1.hexdigest password + settings.salt

		user.update_attributes(:password => hashedPassword)

		# Change the validation token
		currentTime = Time.now.to_i
		hash = Digest::SHA1.hexdigest user[:name] + currentTime.to_s + user[:email] + settings.salt
		user.update_attributes(:validationToken => hash)

		return "Password changed. You may now use your new password"

	end

	# got forgot password
	post '/:name/forgotPassword' do

		request_payload = JSON.parse request.body.read

		name = request_payload["name"]
		email = request_payload["email"]

		emailView = User.by_email.key(email)
		if emailView.rows.length == 0
			return ""
		end

		user = User.get emailView.rows[0].id

		message = <<-MESSAGE_END
Hello, #{user[:name]}

This e-mail is sent to you because you said your lost your password.

If you didn't expect this, please feel free to ignore this mail or throw it in the trash.

Otherwise please click the following link to change your password:

#{settings.front_end_address}/en/#forgotPassword=#{user[:validationToken]}&validateUsername=#{user[:name]}

Astrobunny
		MESSAGE_END

		Pony.mail({
			:to => user[:email],
			:from => 'no-reply@astrobunny.net', 
			:subject => 'Bunnylabs Forgotten Password Department', 
			:body => message,
			:via => :smtp,
			:via_options => {
				:address              => 'smtp.gmail.com',
				:port                 => '587',
				:enable_starttls_auto => true,
				:user_name            => ENV['MAIL_USERNAME'],
				:password             => ENV['MAIL_PASSWORD'],
				:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
				:domain               => "astrobunny.net" # the HELO domain provided by the client to the server
			}
		})

		return ""

	end

end
