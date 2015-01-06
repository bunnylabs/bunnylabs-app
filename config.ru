require 'sinatra/base'
require 'rack/cors'
require 'yaml'

Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }

BasicController.configure :development do

	use Rack::Cors do
	  allow do
	    origins 'localhost:4567', '127.0.0.1:4567'

	    resource '/*',
	    	:headers => :any,
	        :methods => [:get, :post, :put, :delete, :options]
	  end
	end

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
end
 
BasicController.configure :production do

	use Rack::Cors do
	  allow do
	    origins 'bunnylabs.astrobunny.net'

	    resource '/*',
	    	:headers => :any,
	        :methods => [:get, :post, :put, :delete, :options]
	  end
	end

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
end


# Models 

Dir.glob('./{models}/*.rb').each { |file| require file }

# Routes

map('/') { run WebsiteController }
map('/sessions/') { run SessionController }
map('/users/') { run UserController }
