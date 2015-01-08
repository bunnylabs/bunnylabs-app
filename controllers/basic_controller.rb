require 'sinatra'
require 'couchrest_model'
require 'active_support/all'
require 'octokit'

class BasicController < Sinatra::Base

	not_found do
	  'i think you are as lost as i am'
	end

	set :salt, "HAHAHAHA"
end
