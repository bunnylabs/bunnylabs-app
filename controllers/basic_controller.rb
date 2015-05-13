require 'sinatra'
require 'couchrest_model'
require 'active_support/all'
require 'octokit'
require 'mail'

class BasicController < Sinatra::Base

	not_found do
	  'Requested resource is not available'
	end

	# Sitewide control
	set :github_registration_enabled, true
	set :basic_registration_enabled, true

	configure :development do
		CouchRest::Model::Base.configure do |config|
			config.mass_assign_any_attribute = true
			config.model_type_key = 'couchrest-type'
			config.connection = {
				:protocol => 'http',
				:host     => 'localhost',
				:port     => '5984',
				:prefix   => 'bunnylabs',
				:suffix   => nil,
				:join     => '_',
				:username => 'bunnylabs-app',
				:password => 'daysofdash'
			}
		end

		set :front_end_address, "http://localhost:4567"
	end
	 
	configure :production do
		CouchRest::Model::Base.configure do |config|
			config.mass_assign_any_attribute = true
			config.model_type_key = 'couchrest-type'
			config.connection = {
				:protocol => 'https',
				:host     => ENV['DATABASE_HOST'],
				:port     => ENV['DATABASE_PORT'],
				:prefix   => ENV['DATABASE_NAME'],
				:suffix   => nil,
				:join     => '_',
				:username => ENV['DATABASE_USERNAME'],
				:password => ENV['DATABASE_PASSWORD']
			}
		end

		set :front_end_address, "https://bunnylabs.astrobunny.net"
	end

	# Other system-specific secrets
	set :salt, ENV['BUNNYLABS_SALT']
	set :github_client_id, ENV['GITHUB_CLIENT_ID']
	set :github_client_secret, ENV['GITHUB_CLIENT_SECRET']

	def t(msg, *args)
		arguments = {}
		if args[0]
			arguments = args[0]
			puts arguments.inspect
		end
		arguments[:locale] = params[:lang]
		I18n.translate( msg, arguments )
	end


end
