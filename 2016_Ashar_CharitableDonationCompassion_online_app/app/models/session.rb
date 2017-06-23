class Session < ActiveRecord::Base
	has_many :last_levels
	has_many :elements, :through => :last_levels
	has_one :survey
	
	serialize :properties, Hash
	include ActiveRecord::Transitions
	
	HARDSHIPS_PER_SUBJECT = 16  #must be divisible by 4, so half black and half male
	NumElements_Hardship = 1
	NumElements_General = 2
	Cycle = false #true=keep cycling in targets, false= move on to questionaires
	
	state_machine do
		state :irb
		state :instructions
		state :targets
		state :measures
		state :demographics
		state :done
		
		event :next do
		  transitions :to => :instructions, :from => :irb
		  transitions :to => :demographics, :from => :instructions
		  transitions :to => :targets, :from => :demographics
		  transitions :to => :measures, :from => :targets
		  transitions :to => :done, :from => :measures
		  transitions :to => :done, :from => :done
		  
		end
	end
	
	#Generate a text:  name + condition + elements
	# auto-increments the name and hardship counters
	# return nil if no more hardships
	def next_bio
		hardship = get_next_property(:hardship)
		return nil if hardship == nil  #done
		
		name = get_next_property(:name)
		image = get_next_property(:image)
		text = Sentence.formatted(name.name + ' ' + hardship.description, name.gender) + " "

		t = Target.create(:image => image, :hardship => hardship, :name => name)
		
		#for each el (weighted and randomly chosen), 
		#take a sentence, using lastLevel to get a new sentence
		(els = chooseEls(hardship)).each_with_index { |el, i|
			sent = el.getSentence(self, image, hardship)
			t.sentence_targets << SentenceTarget.create(:sentence => sent, :order => i)
			text = text + sent.formatted(image.gender) + ' '
		}
		
		t.bio = text
		survey.targets << t
		save
		return t
	end
	
	def chooseEls(hardship)
		ret = []

		els = hardship.elements #will never repeat a sentence for the hardships
		NumElements_Hardship.times {
		
			weightedArr = []			
			ret.each { |chosen| els.delete(chosen)} #if an el was already chosen, cannot be chosen again - remove it
			els.each { |el| el.weight.to_i.times { weightedArr << el} } #created weighted array to sample from
			ret << weightedArr.sample #choose one and add it to return val
		}
	#	p 'ret is: ' + ret.to_s
		
		#never repeat a sentence for general elements:
		#include element if last_level does yet exist or if exists but not maxed out
		els = Element.generalElements.map { |el| 
			ll = self.last_levels.find_by_element_id(el.id)
			(ll.nil? || ll.level != ll.first_level) ? el : nil
		}
		els.compact!
	#	p 'els is :' + els.to_s
		
		NumElements_General.times {
			weightedArr = []
			ret.each { |chosen| els.delete(chosen)} #sample, no replacement of chosen elements
			els.each { |el| el.weight.to_i.times { weightedArr << el} } #created weighted array to sample from
			ret << weightedArr.sample #choose one and add it to return val
		}
		ret
	end
	
	#move session to next thng it should do, and return what is needed
	# i.e., if in targets, return next target, and if in measures, return next measure
	def advance()
	 
		case state
		when 'irb', 'instructions'
			next!
		when 'demographics'
			next!
			ret = next_bio
			
		when 'targets'  #return next target, or if no more targets transition targets -> measures and return first measure
			ret = next_bio 
			if ret == nil				
				next!
				ret = get_next_property(:measure, false)
			end	
			
		when 'measures' #return next measure, or if no more measures transition -> done
			ret = get_next_property(:measure,false)
			if ret == nil #generate code and move to done				
				ret = set_completion_code
				self.survey.score
				next!
			end
		when 'done'
			ret = last
		end
		
		save #after next-ing
		setlast(ret)
		return ret
	end

	def last		
		case state			
		when 'targets'
			ret = Target.find(properties[:last_target])
		when 'measures'
			ret = get_last_property(:measure)
		when 'done'
			ret = properties[:don_item_id].nil? ? nil : QItemScore.find(properties[:don_item_id])
		else
			ret = nil
		end
		return ret
	end
	
	def target_ratings
		properties[:target_ratings_order].map { |id| QItem.find(id)}
	end
		
	
################
#	private 
################
		
	def setlast(x)
		if state == 'targets'
			properties[:last_target] = x.id
		elsif state == 'done'
			properties[:don_item_id] = x.nil? ? nil : x.id
		end
	  self.save
	end


	#get the next name, hardship, or measure of the previous item
	#don't change counter
	def get_last_property(property)
		return nil if prop_curr(property) > prop_arr(property).length  #at end

		model = 
		case property
		when :name
			Name
		when :hardship
			Hardship
		when :measure
			QMeasure
		when :image
			Image
		else
			p 'WARNING' # TODO BETTER WARNING
		end
		
		#find item and increment cntr
		model.find(prop_arr(property)[prop_curr(property) - 1])
	end
	
	#get the next name, hardship, or measure and increment counter
	#if at end, do we cycle or return nil?
	def get_next_property(property, cycle=Cycle)
		return nil if prop_curr(property) >= prop_arr(property).length  #at end

		model = 
		case property
		when :name
			Name
		when :hardship
			Hardship
		when :measure
			QMeasure
		when :image
			Image
		else
			p 'WARNING' # TODO BETTER WARNING
		end
		
		#find item and increment cntr
		ret = model.find(prop_arr(property)[prop_curr(property)])
		
		i = prop_curr(property) + 1
		i = i % prop_arr(property).length if cycle
		set_prop_curr(property, i)
		return ret
	end
	
	#handy getters and setters
	def prop_arr(property)
		return properties[property.to_s + '_ids']
	end
	def prop_curr(property)
		return properties['curr_' + property.to_s]
	end
	def set_prop_arr(property, obj)
		properties[property.to_s + '_ids'] = obj
		self.save
	end
	def set_prop_curr(property, obj)
		properties['curr_' + property.to_s] = obj
		self.save
	end
	def properties
		self[:properties] 
	end
	def set_completion_code
		#choose one donation randomly
		don_item = survey.q_item_scores.find_all_by_q_item_id(QMeasure.dq1).sample
		
		#total num of responses
		n_resp = survey.q_item_scores.size
		
		#random num
		num = (0..9).to_a
		c = (0...32).to_a.map { |e| num[rand(10)] }.join('')[0..5].to_s
		
		#random, sess id, donation on 1 to 10 times 18, number answered
		if don_item.nil?
			self.completion_code = [c, self.id, n_resp].join('_')
			Donation.create(:session => self).save
		else
			self.completion_code = [c, self.id, (don_item.response - 1) * 18, don_item.target.hardship.id, n_resp].join('_')
			Donation.create(:session => self, :hardship => don_item.target.hardship, :amount => (don_item.response - 1) / 10.0).save
		end
		
		
		
		save
		return don_item
	end
	
	#sets property_ids to value and curr_property to 0
	def init_property(property, value)
		set_prop_arr(property,value)
		set_prop_curr(property, 0)
	end	
	
	after_initialize :init
	def init
		#on first initialization only
		if properties == nil
			self[:properties] = {}		

			#choose targets based on pictures.
			# half white, half black, half male, half female
			n = HARDSHIPS_PER_SUBJECT / 4
			images = Image.joins(:ethnicity).where('ethnicities.code' => 'B', :gender => true).sample(n)
			images.concat Image.joins(:ethnicity).where('ethnicities.code' => 'B', :gender => false).sample(n)
			images.concat Image.joins(:ethnicity).where('ethnicities.code' => 'W', :gender => true).sample(n)
			images.concat Image.joins(:ethnicity).where('ethnicities.code' => 'W', :gender => false).sample(n)
			images.shuffle!

			#for each picture, choose an appropriate name which was not previously chosen
			names = []			
			images.each_with_index { |image, i|
				begin 
					name = Name.find_by_ethnicity_and_gender(image.ethnicity, image.gender)
				end while names.include?(name)
				names << name
			}
			
			init_property(:hardship, (1..[HARDSHIPS_PER_SUBJECT,Hardship.count].min).to_a.shuffle)
			init_property(:name, names.map { |t| t.id})
			init_property(:image, images.map { |t| t.id})
			init_property(:measure, QMeasure.measures.shuffle.map { |t| t.id})
			
			#target ratings order
			properties[:target_ratings_order] = QMeasure.target_ratings.map {|tr| tr.id}
			
			self.survey = Survey.create
			self.survey.save
			save
		end
	end

end
