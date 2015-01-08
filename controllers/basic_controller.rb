require 'sinatra'
require 'couchrest_model'
require 'active_support/all'

class BasicController < Sinatra::Base

	not_found do
	  'Requested resource is not available'
	end

	set :salt, "HAHAHAHA"
end
