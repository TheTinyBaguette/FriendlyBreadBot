#Attempting to abstract away all the 'resource' metadata and management into this class.
#This class knows where things are stored (on Heroku at least)
#Could have 'dev helper' features for working on different platforms (heroku, local linux, ?).
#Sets up all object variables needed by Bot. One Stop Shop.

#Key feature design details: 

# This bot builds Twitter Quick Reply (menu) lists from a set of local data files. These files are served from the webhook listener server... 
# Bot supports: 
#     * Single list of locations (up to 20)
#           * Snowbot uses snow resort locations, @FloodSocial uses Texas cities. 
#     * Look-up for a single list of curated links.
#           * Snowbot presents a short of list of suggested 'learn more' URLs.
#     * Serves photos hosted in single directory of JPEGs.
#           * Snowbot displays random snow photos.
#     * Single list of playlist URLs. Geo-tagged music, why not?


class GetResources
	require 'csv'

	attr_accessor :facts_home,
	              :facts_list,     #CSV with file name and caption. That's it.
	              
	              :puns_home,
	              :puns_list, #This class knows the configurable location list.
	              
	              :friendly_message_home,
	              :friendly_message_list
	
	def initialize()

		#Load resources, populating attributes.
		@facts_home = 'app/config/data/facts' #On Heroku at least.
		if not File.directory?(@facts_home)
			@facts_home = '../config/data/photos'
		end
		@facts_list = []
		@facts_list = get_facts

		@puns_home = 'app/config/data/puns' #On Heroku at least.
		if not File.directory?(@puns_home)
			@puns_home = '../config/data/puns'
		end
		@puns_list = []
		@puns_list = get_puns

		@friendly_message_home = 'app/config/data/friendlyMessages' #On Heroku at least.
		if not File.directory?(@friendly_message_home)
			@friendly_message_home = '../config/data/friendlyMessages'
		end
		@friendly_message_list = []
		@friendly_message_list = get_friendly_messages
	end

	#Take resource file with '#' comment lines and filter them out.
	#Filter out '#' comment lines.
	def filter_list(lines)
		list = []
		
		lines.each do |line|
			if line[0][0] != '#'
				#drop dynamically from array
				list << line
			end
		end
		list
	end

	def get_facts
		list = []
		
		begin
			list = filter_list(CSV.read("#{@facts_home}/facts.csv", {:col_sep => ";"}))
		rescue
		end
		
		list
	end

	def get_puns
		list = []
		
		begin
			list = filter_list(CSV.read("#{@puns_home}/puns.csv", {:col_sep => ";"}))
		rescue
		end
		
		list
	end

	def get_friendly_messages
		list = []
		
		begin
			list = filter_list(CSV.read("#{@friendly_message_home}/friendlyMessages.csv", {:col_sep => ";"}))
		rescue
		end	
		list
	end

  #=======================
	if __FILE__ == $0 #This script code is executed when running this file.
		retriever = GetResources.new
		
		#Example code for loading location file --------
		retriever.locations_home = '/Users/jmoffitt/work/snowbotdev/data/locations'
		locations = retriever.get_locations
		
		locations.each do |resorts|  #explore that list
			puts resorts
		end
	end
end
