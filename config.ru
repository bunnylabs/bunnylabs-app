require 'sinatra/base'
require 'rack/cors'
require 'rack/throttle'
require 'yaml'
require 'i18n'

Dir.glob('./{helpers,controllers,models}/*.rb').each { |file| require file }


# We're going to load the paths to locale files,
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
I18n.enforce_available_locales = true

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
	
	require 'newrelic_rpm'
	
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
map('/public/') { run PublicController }
