require 'sinatra/base'
 
Dir.glob('./{models,helpers,controllers}/*.rb').each { |file| require file }
 
ApplicationController.configure :development do
	configure do
	  $COUCH = CouchRest.new 'http://localhost:5984'
	  $COUCH.default_database = 'bunnylabs'
	  $COUCHDB = $COUCH.default_database
	end
end
 
ApplicationController.configure :production do
end

map('/') { run WebsiteController }
