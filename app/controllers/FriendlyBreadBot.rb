require 'sinatra'
require 'base64'
require 'json'

require_relative "../../app/helpers/event_manager"

class FriendlyBreadBot < Sinatra::Base

	def initialize
		puts "Starting up web app."
		super()
	end

	#Load authentication details
	keys = {}
	set :dm_api_consumer_secret, ENV['CONSUMER_SECRET'] #Account Activity API with OAuth

	set :title, 'friendlybreadbot'

	def generate_crc_response(consumer_secret, crc_token)
		hash = OpenSSL::HMAC.digest('sha256', consumer_secret, crc_token)
		return Base64.encode64(hash).strip!
	end

	get '/' do
		'<p><b>Welcome to friendlybreadbot, home of the @FriendlyBreadBot...</b></p>
     <p>I just want people to be happy and have a good time... </p>
     <p>I will try to respond to messages and tell you good things</p>
     <p></p>
     <p>#FriendlyBreadBot...</p>'
	end

	# Receives challenge response check (CRC).
	get '/friendlybreadbot' do
		crc_token = params['crc_token']

		if not crc_token.nil?

			#puts "CRC event with #{crc_token}"
			#puts "headers: #{headers}"
			#puts headers['X-Twitter-Webhooks-Signature']

			response = {}
			response['response_token'] = "sha256=#{generate_crc_response(settings.dm_api_consumer_secret, crc_token)}"

			body response.to_json
		end

		status 200

	end

	# Receives DM events.
	post '/friendlybreadbot' do
		#puts "Received event(s) from DM API"
		request.body.rewind
		events = request.body.read

		manager = EventManager.new
		manager.handle_event(events)

		status 200
	end
end
