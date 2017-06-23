class QItemSet < ActiveRecord::Base

  	IPIP_SCALES = 4
  	SHORT_SCALES = (105..134).to_a # NEO-PI-R subset of AMBI
  	LONG_SCALES = (105..307).to_a   # full AMBI

  	# return a set of items selected based on specified rules
  	def self.getItems(length="short")

  		# determine whether to show domains or facets
  		basic_scales = (length == "long") ? LONG_SCALES : SHORT_SCALES

  		# determine number of items
  		n = (length == "long") ? 181 : 108

  		# track active scales in session
  		active_scales = []

  		# get all scales in DB
  		all_scales = QScale.find(:all).map { |s| s.id }
      # # get all scales for which subject has score
      scored_scales = [] # ScaleScore.find(:all, :conditions=> "user_id='#{user}'").map { |s| s.id }
      # # available scales
      available_scales = all_scales - scored_scales

  		# RULE-BASED SELECTION OF ITEMS
  		items = []
  		# will need to know all the items user has already filled
      user_items = [] # ItemScore.find(:all, :conditions=> "user_id='#{user}'").map { |i| i.id }

  		# include any items that belong to mandatory scales (e.g., big 5)
  		unless ((scales = basic_scales & available_scales).empty?)
  		  active_scales += scales
  			available_scales = available_scales - basic_scales
  			item_ids = QAssignment.find(:all, :conditions=>["q_scale_id IN (?)", (scales)]).map { |a| a.q_item_id }
  			basic_items = QItem.find(item_ids).map { |i| i.id }
  			#~ basic_item_ids = basic_items.map { |i| i.id
  			items += (basic_items - user_items)
  		end

  		# include additional IPIP scales
  		unless available_scales.empty? or items.length >= n
  			scales = available_scales.sort_by { rand }.slice!(0,IPIP_SCALES)
  			active_scales += scales
  			item_ids = QAssignment.find(:all, :conditions=>["q_scale_id IN (?)", (scales)]).map { |a| a.q_item_id }
  			ipip_items = QItem.find(item_ids).map { |i| i.id }
  			#~ basic_item_ids = basic_items.map { |i| i.id }
  			items += (ipip_items - user_items)
  		end

  		# include filler items
  		items.uniq!
  		if ((remain = n - items.length) > 0) 
  			selected_ids = items.map { |i| i.id }
  			valid = (1..QItem.count).to_a - (selected_ids | user_items )   # only use items not already scored or just selected
  			items += QItem.find(valid.sort_by { rand }[0,remain]).map { |i| i.id }
  		end
      {:items=>items, :scales=>active_scales}
  	end

  end
