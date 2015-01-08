require_relative 'basic_controller.rb'

require 'net/http'

class SessionController < BasicController
	
	#get session info
	get '/current' do

		authToken = request.env['HTTP_AUTHENTICATION_TOKEN']

		begin
			session = Session.get authToken

			user = User.get session[:userid]

			returnObject = {
				:username => user[:name]
			}

			return returnObject.to_json

		rescue
			halt 401
		end
	end

	#login
	post '/' do

		request_payload = JSON.parse request.body.read

		hashedPassword = Digest::SHA1.hexdigest request_payload["password"] + settings.salt

		user = UserUtils.get_user_named request_payload["username"]

		if user == false or 
			user[:password] != hashedPassword or 
			!user[:validated] or 
			UserUtils.is_normal_username request_payload["username"] == false

			status 403
			return "Wrong username/password combination. Did you forget to click the validation link?"
		end

		session = UserUtils.login_user user, request.ip, 14.days.from_now.to_i

		return session.id

	end

	#logout
	delete '/current' do

		authToken = request.env['HTTP_AUTHENTICATION_TOKEN']

		begin
			session = Session.get authToken

			user = User.get session[:userid]

			user.update_attributes(:currentSession => "")

			return "Logged out. Thank you"

		rescue
			halt 401
		end
	end

	#login using github
	get '/githubCallback' do

		message = {
			"type" => "githubLogin",
			"authToken" => "",
			"error" => ""
		}

		if settings.github_registration_enabled
			begin

				code = params[:code]

				uri = URI('https://github.com/login/oauth/access_token')
				res = Net::HTTP.post_form(uri, 
					'client_id' => settings.github_client_id, 
					'client_secret' => settings.github_client_secret,
					'code' => code
					)

				result = Rack::Utils.parse_nested_query(res.body)

				accessToken = result['access_token']

				client = Octokit::Client.new(:access_token => accessToken)

				userInfo = client.user

				properUsername = "github::#{userInfo.login}"

				user = UserUtils.get_user_named properUsername

				if user == false

					#absorb the email
					emails = client.emails

					primaryEmail = ""

					emails.each do |email|
						if email[:primary] == true
							primaryEmail = email[:email]
						end
					end

					result = UserUtils.create_user properUsername, 
													userInfo.login + userInfo.id.to_s + settings.salt, # basically nonsense 
													primaryEmail, 
													accessToken,
													settings.salt

					user = UserUtils.get_user_named properUsername
				end

				session = UserUtils.login_user user, request.ip, 14.days.from_now.to_i

				message["authToken"] = session.id

			rescue => e
				message["error"] = "Internal server error"
			end
		else
			message["error"] = "Registration has been disabled"
		end

		redirect "#{settings.front_end_address}/githubLoginReceiver.html?#{message.to_query}"
	end

end
