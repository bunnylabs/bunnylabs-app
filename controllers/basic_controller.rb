require 'sinatra'
require 'couchrest_model'

class BasicController < Sinatra::Base

	not_found do
	  'i think you are as lost as i am'
	end

	error 403 do
	  'you shall not pass'
	end
	
end
