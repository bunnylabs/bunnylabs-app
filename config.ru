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
end


# Models 

Dir.glob('./{models}/*.rb').each { |file| require file }

# Routes

map('/') { run WebsiteController }
map('/sessions/') { run SessionController }
map('/users/') { run UserController }
