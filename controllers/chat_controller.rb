require_relative 'authenticated_controller.rb'

require 'faye/websocket'
require 'json'

class ChatBackend
	KEEPALIVE_TIME = 15 # in seconds

	def initialize
		@rooms = {}
	end

	def handle
	end
end




class ChatController < AuthenticatedController


	get '/' do
	  "nyoron~"
	end

	get '/:room/talk' do
		if Faye::WebSocket.websocket?(request.env)
			ws = Faye::WebSocket.new(request.env)

			ws.class.module_eval do
				attr_accessor :roomname
				attr_accessor :username
			end

			session = Session.get params[:auth]

			user = User.get session[:userid]

			ws.roomname = params[:room]
			ws.username = user[:name]

			if !defined? @@rooms
				@@rooms = {}
			end

			ws.on(:open) do |event|
				puts ': On Open: ' + ws.roomname

				if !@@rooms.has_key?(ws.roomname)
					@@rooms[ws.roomname] = {}
				end

				@@rooms[ws.roomname][ws.username] = ws

				@@rooms[ws.roomname].each do |username,targetws|

					joinstatus = {
						type: "status",
						message: ws.username + " has joined the conversation"
					}

					targetws.send(joinstatus.to_json)
				end

			end

			ws.on(:message) do |msg|
				puts ':' + msg.data

				begin

					data = JSON.parse(msg.data)

					type = data["type"]
					name = data["name"]
					pic = data["pic"]
					msg = data["message"]

					if type == "message"
						
						@@rooms[ws.roomname].each do |username,targetws|

							relayedMessage = {
								type: "message",
								name: name,
								pic: pic,
								message: msg
							}

							targetws.send(relayedMessage.to_json)
						end

					elsif type == "ping"

					end

				rescue

				end

				#ws.send(msg.data.reverse)  # Reverse and reply
			end

			ws.on(:close) do |event|
				puts ': On Close'

				@@rooms[ws.roomname].except!(ws.username)


				@@rooms[ws.roomname].each do |username,targetws|

					joinstatus = {
						type: "status",
						message: ws.username + " has left the conversation"
					}

					targetws.send(joinstatus.to_json)
				end
			end

			ws.rack_response

		else
			"nyan~"
		end
	end

end
