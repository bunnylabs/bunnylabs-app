require_relative 'basic_controller.rb'

class AuthenticatedController < BasicController

	# Authenticate the user
	before do
		authToken = params[:auth]

		begin
			session = Session.get authToken

			user = User.get session[:userid]

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
	
end
