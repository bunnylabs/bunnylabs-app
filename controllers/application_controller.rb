require 'sinatra'
require 'omniauth'
require 'couchrest_model'

class ApplicationController < Sinatra::Base
 
	use Rack::Session::Pool, :cookie_only => false, :defer => true
	use OmniAuth::Strategies::Developer

	not_found do
	  'i think you are as lost as i am'
	end

	error 403 do
	  'you shall not pass'
	end
end
