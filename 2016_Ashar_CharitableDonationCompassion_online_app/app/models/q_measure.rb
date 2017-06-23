class QMeasure < ActiveRecord::Base
  
    has_many :q_scales
    has_many :q_inclusions
    has_many :studies, :through => :q_inclusions
    has_many :q_assignments
    has_many :q_items, :through => :q_assignments
    
    #get array of target ratings items.
	# the two donation q's are always last, the rest are in random order.
	#n is number of items to return (not counting donation q's)
	# if n not passed in, return all items
	def self.target_ratings
		items = targ_measure.q_items
		
		#put last two donation questions at end, and shuffle all the rest
		temp = items - [dq1, dq2]
		temp.shuffle! 
		items = temp + [dq1, dq2]
		return items
	end
	

	def self.targ_measure
		QMeasure.where(:name => 'Target Ratings')[0]	
	end
	
	def self.measures        # Eager load measures with scales and assignments
		ret = QMeasure.find(:all, :include => {:q_scales => :q_assignments})
		ret.delete(targ_measure)
		ret
	end

	def self.dq1
		QItem.select(:*).where("text like '%donate%'")[0]
	end
	def self.dq2
		QItem.select(:*).where("text like '%likely%'")[0]
	end
    
end