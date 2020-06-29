#POST requests to /webhooks/twitter arrive here.
#Twitter Account Activity API send events as POST requests with DM JSON payloads.

require 'json'
#Two helper classes... 
require_relative 'send_direct_message'

class EventManager
	#Design: Identifying explicit commands is easy and can restrict text length based on its own length.
	#        If you want to be more flexible,
	COMMAND_MESSAGE_LIMIT = 12	#Simplistic way to detect an incoming, short, 'commmand' DM.
	
	attr_accessor :DMsender

	def initialize
		#puts 'Creating EventManager object'
		@DMSender = SendDirectMessage.new
	end

	def handle_quick_reply(dm_event)

		response_metadata = dm_event['message_create']['message_data']['quick_reply_response']['metadata']
		user_id = dm_event['message_create']['sender_id']

		#Default options
		if response_metadata == 'help'
			@DMSender.send_system_help(user_id)
		
		elsif response_metadata == 'return_home'
			puts "Returning to home in event manager...."
			@DMSender.send_welcome_message(user_id)
			
		#Custom options	
		elsif response_metadata == 'friendly_message'
			@DMSender.send_friendly_message(user_id)

		elsif response_metadata == 'bread_fact'
			@DMSender.send_bread_fact(user_id)

		elsif response_metadata == 'pun'
			@DMSender.send_pun(user_id)

		else #we have an answer to one of the above.
			puts "UNHANDLED user response: #{response_metadata}"
		end
		
	end

	def handle_command(dm_event)

		#Since this DM is not a response to a QR, let's check for other 'action' commands

		request = dm_event['message_create']['message_data']['text']
		user_id = dm_event['message_create']['sender_id']

		if request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'bot' or request.downcase.include? 'home' or request.downcase.include? 'main' or request.downcase.include? 'hello' or request.downcase.include? 'back')
			@DMSender.send_welcome_message(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'message')
			@DMSender.send_friendly_message(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'fact')
			@DMSender.send_bread_fact(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'pun')
			@DMSender.send_pun(user_id)
		elsif request.length <= COMMAND_MESSAGE_LIMIT and (request.downcase.include? 'help')
			@DMSender.send_system_help(user_id)
		else
			# This is where you'd plug in more fancy message processing...
			#message = "I only support a basic set of commands, send 'help' to review those... "
			#@DMSender.send_custom_message(user_id, message)
		end
	end

	#responses are based on options' Quick Reply metadata settings.
	#pick_from_list, select_on_map, location list items (e.g. 'location_list_choice: Austin' or 'Fort Worth')
	#map_selection (triggers a fetch of the shared coordinates)

	def handle_event(events)

		events = JSON.parse(events)

		if events.key? ('direct_message_events')

			dm_events = events['direct_message_events']

			dm_events.each do |dm_event|

				if dm_event['type'] == 'message_create'

					#Is this a response? Test for the 'quick_reply_response' key.
					is_response = dm_event['message_create'] && dm_event['message_create']['message_data'] && dm_event['message_create']['message_data']['quick_reply_response']

					if is_response
						handle_quick_reply dm_event
					else
						handle_command dm_event
					end
				else
					puts "A unhandled DM type arrived via Twitter Account Activity API...  "
				end
			end
		else
			puts "Hey, a unhandled Account Activity event has been send from the Twitter side... A new follower? A Tweet liked? "
		end
	end
end
