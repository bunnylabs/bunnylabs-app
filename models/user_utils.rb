require_relative 'user.rb'
require_relative 'session.rb'

class UserUtils

	def self.is_normal_username username

		username.downcase!

		# Normal users cannot make usernames with special symbols
		if /^[[:alnum:]_]+$/.match(username) == nil
			return false
		end

		return true
	end

	def self.login_user user, ip, expiry

		pp user
		currentTime = Time.now.to_i

		Time.at(currentTime).to_datetime

		session = Session.create :userid => user.id,
						:loginTime => currentTime,
						:ip => ip,
						:lastUseTime => currentTime,
						:expiryTime => expiry

		user.update_attributes(:currentSession => session.id)

		return session
	end

	def self.get_user_named username
		username.downcase!

		view = User.by_name.key(username)

		if view.rows.length == 0 
			return false
		end

		user = view.rows[0]
		user = User.get user.id
		return user
	end

	def self.user_exists? username

		username.downcase!

		view = User.by_name.key(username)

		if view.rows.length == 0 
			return false
		end

		return true
	end

	def self.create_user username, password, email, githubAccessToken, salt

		username.downcase!

		nameView = User.by_name.key(username)
		emailView = User.by_email.key(email)

		if nameView.rows.length != 0
			return {:status => 409, :result => "User name #{username} already exists"} 
		end

		if emailView.rows.length != 0
			return {:status => 409, :result => "E-mail #{email} already exists"} 
		end

		registrationTime = Time.now.to_i
		hashedPassword = Digest::SHA1.hexdigest password + salt
		hash = Digest::SHA1.hexdigest username + registrationTime.to_s + email + salt

		user = User.create :name => username,
							:email => email,
							:password => hashedPassword,
							:validationToken => hash,
							:registrationTime => registrationTime,
							:githubAccessToken => githubAccessToken

		user.update_attributes(:identityId => user.id)

		return {:status => 200, :result => username}
	end
end
