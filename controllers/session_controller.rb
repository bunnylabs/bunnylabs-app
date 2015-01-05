require_relative 'basic_controller.rb'

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

		request_payload["username"].downcase!

		nameView = User.by_name.key(request_payload["username"])
		hashedPassword = Digest::SHA1.hexdigest request_payload["password"] + settings.salt

		if nameView.rows.length > 1
			status 409
			return "Contact the admin"
		end

		if nameView.rows.length == 0
			status 403
			return "Wrong username/password combination. Did you forget to click the validation link?"
		end

		user = nameView.rows[0]

		user = User.get user.id

		if user[:password] != hashedPassword or !user[:validated]
			status 403
			return "Wrong username/password combination. Did you forget to click the validation link?"
		end

		currentTime = Time.now.to_i

		Time.at(currentTime).to_datetime

		expiryTime = 14.days.from_now.to_i

		session = Session.create :userid => user.id,
						:loginTime => currentTime,
						:ip => request.ip,
						:lastUseTime => currentTime,
						:expiryTime => expiryTime

		user.update_attributes(:currentSession => session.id)

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

end
