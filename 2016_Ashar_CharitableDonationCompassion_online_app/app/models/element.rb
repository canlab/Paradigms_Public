class Element < ActiveRecord::Base
	has_many :sentences
	has_and_belongs_to_many :hardships
	has_many :last_levels
	has_many :sessions, :through => :last_levels
	
	#all elements which don't have a specific hardship
	def self.generalElements
		return find_all_by_hasHardship(false)
	end
	
	# 1 is normal weight. can't go below 1.  higher weighted elements will be chosen more frequently
	def weight
		read_attribute(:weight) < 1 ? 1 : read_attribute(:weight)
	end
	
	#private
	
	#get a sentence for this element
	#find the last level session had for this element, increment last level,
	#and return sentence where level=new last level for this element
	#true is male
	def getSentence(sess, image, hardship)		
		
		sub =  #get subcat if exists
		case self.name 
		when 'religion'
			image.ethnicity.code
		else
			nil
		end
		
		#get last level, or initiate if doesn't exist
		ll = last_levels.find_by_session_id_and_subcat(sess, sub)
		lev = rand(numLevels.to_i)
		ll = last_levels.create(:session => sess, :level => lev, :first_level => lev, :subcat => sub) if ll == nil
		
		hardship = nil if !self.hasHardship?
		
		#increment until we have the next one
		begin
			ll.level = (ll.level + 1) % numLevels.to_i
		end while (s = sentences.find_by_level_and_subcat_and_hardship_id(ll.level, sub, hardship)) == nil
		
		ll.save		
		return s
	end
end
