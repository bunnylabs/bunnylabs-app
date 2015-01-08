require 'sinatra/base'
require 'rack/cors'

Dir.glob('./{helpers,controllers}/*.rb').each { |file| require file }

BasicController.configure :development do
	configure do
		$COUCH = CouchRest.new 'http://bunnylabs-app:daysofdash@localhost:5984'

		$COUCH.default_database = 'bunnylabs'
		$COUCHDB = $COUCH.default_database
	end

	use Rack::Cors do
	  allow do
	    origins 'localhost:4567', '127.0.0.1:4567'

	    resource '/*',
	    	:headers => :any,
	        :methods => [:get, :post, :put, :delete, :options]
	  end
	end
end
 
BasicController.configure :production do
	configure do
		$COUCH = CouchRest.new "https://#{ENV['DATABASE_LOGIN']}@#{ENV['DATABASE_HOST']}"
		$COUCH.default_database = "#{ENV['DATABASE_NAME']}"
		$COUCHDB = $COUCH.default_database
	end

	use Rack::Cors do
	  allow do
	    origins 'bunnylabs.astrobunny.net'

	    resource '/*',
	    	:headers => :any,
	        :methods => [:get, :post, :put, :delete, :options]
	  end
	end
end


# Models 

Dir.glob('./{models}/*.rb').each { |file| require file }

# Routes

map('/') { run WebsiteController }
map('/sessions/') { run SessionController }
map('/users/') { run UserController }
map('/admin/') { run AdminController }
