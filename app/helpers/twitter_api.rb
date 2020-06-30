require 'twitter' #Opens doors to the rest of the standard Twitter APIs.
#https://github.com/sferik/twitter/blob/master/examples/Configuration.md

class TwitterAPI

	attr_accessor :keys,
	              :upload_client,
	              :base_url, # 'https://api.twitter.com/' or 'upload.twitter.com' or ?
	              :uri_path #No default.

		def initialize()

			#puts "Creating Twitter (public) API object."

      @base_url = 'upload.twitter.com'
			@uri_path = '/1.1/media/upload'

			#Get Twitter App keys and tokens. Read from 'config.yaml' if provided, or if running on Heroku, pull from the
			#'Config Variables' via the ENV{} hash.
			@keys = {}

			@keys['consumer_key'] = 'VJQQJBrefWZGEf32fWGn7n8Ma'
			@keys['consumer_secret'] = 'mrEv9N67iC2taogKS089pkn41F4oxL4w0JdwZXzOaugFSCatJX'
			@keys['access_token'] = '1042152965312860160-061ah8zIt3Rn8acTMn5NgvhAFIV3Sv'
			@keys['access_token_secret'] = 'ullv8QZm2yZNWXgoxOFz93M0OEoLcg6WTEmmj0JWy5nYc'

			@upload_client = Twitter::REST::Client.new(@keys)
	
	end
  
	def get_media_id(media_path)
		
		#puts "Value of media: #{media_path}"

		media_id = nil

		if media_path != '' and not media_path.nil?
			puts "Calling upload with #{media_path}"
      media_id = @upload_client.upload(File.new(media_path))
		else
			media_id = nil
		end	

		media_id
	
  end

end

