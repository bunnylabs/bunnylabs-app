require_relative 'basic_controller.rb'

class AdminController < BasicController

	# Authenticate the user
	before do
		authToken = params[:auth]

		begin
			session = Session.get authToken

			user = User.get session[:userid]

			if user[:accountType] != "admin"
				halt 403
			end

			if user[:currentSession] != authToken
				halt 401
			end

			currentTime = Time.now.to_i

			if currentTime > session[:expiryTime]
				halt 401
			end

			session.update_attributes(:lastUseTime => currentTime)

		rescue
			halt 403
		end
	end

	get '/users' do
		return User.all.to_json
	end

	get '/usercount' do
		# get the total number of users
		return User.count.to_s
	end

	put '/users/:id/:parameter' do
		newValue = JSON.parse request.body.read

		user = User.get params[:id]

		if user != nil
			user.update_attributes(params[:parameter] => newValue["value"])
		end

		"OK"

	end

	get '/sessions' do
		return Session.all.to_json
	end

	get '/sessioncount' do
		# get the total number of sessions
		return Session.count.to_s
	end

end
