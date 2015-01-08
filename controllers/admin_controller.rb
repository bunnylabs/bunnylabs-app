require_relative 'basic_controller.rb'

class AdminController < BasicController

	# Authenticate the user
	before do
		authToken = request.env['HTTP_AUTHENTICATION_TOKEN']

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
			halt 401
		end
	end

	get '/users' do
		# get all the users
	end

	get '/usercount' do
		# get the total number of users
		return User.count.to_s
	end

	get '/sessions' do
		# get all the sessions
	end

	get '/sessioncount' do
		# get the total number of sessions
		return Session.count.to_s
	end

end
