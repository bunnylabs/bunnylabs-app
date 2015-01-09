require 'sinatra/base'
require 'rack/cors'
require 'rack/throttle'
require 'yaml'

Dir.glob('./{helpers,controllers,models}/*.rb').each { |file| require file }

use Rack::Throttle::Minute, :max => 200

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

# Routes

map('/') { run WebsiteController }
map('/sessions/') { run SessionController }
map('/users/') { run UserController }
map('/admin/') { run AdminController }
