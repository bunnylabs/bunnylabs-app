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
			return t(:registration_disabled)
		end

		request_payload = JSON.parse request.body.read

		if (UserUtils.is_normal_username request_payload["username"]) == false
			status 409
			return t(:invalid_username)
		end

		result = UserUtils.create_user request_payload["username"], 
										request_payload["password"], 
										request_payload["email"], 
										"",
										settings.salt

		if result[:status] == 200

			Thread.new {

				user = UserUtils.get_user_named request_payload["username"]

				message = t(:new_user_email_message, 
					name: request_payload["username"], 
					frontend_address: settings.front_end_address, 
					validation_token: user[:validationToken], 
					validation_name: user[:name], 
					lang: params[:lang]
					)

				Pony.mail({
					:to => request_payload["email"],
					:from => 'no-reply@astrobunny.net', 
					:subject => t(:new_user_email_subject), 
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
			}

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

		return t(:password_changed)

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

		if user

			Thread.new {

				message = t(:new_user_email_message, 
					name: user[:name], 
					frontend_address: settings.front_end_address, 
					validation_token: user[:validationToken], 
					validation_name: user[:name],
					lang: params[:lang]
					)

				Pony.mail({
					:to => user[:email],
					:from => 'no-reply@astrobunny.net', 
					:subject => t(:forgot_password_email_subject), 
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
			}
		end

		return ""

	end

end
