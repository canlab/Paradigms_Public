class Hardship < ActiveRecord::Base
	has_many :sentences
	has_many :donations
	has_and_belongs_to_many :elements
	

	#given an array of elements, creates a subarray of n elements.
	#chosen randomly by weights
	def chooseEls(nHardship, nGeneral) 
		
		ret = []
		nHardship.times {
			weightedArr = []
			els = self.elements
			ret.each { |chosen| els.delete(chosen)} #if an el was already chosen, cannot be chosen again - remove it
			els.each { |el| el.weight.to_i.times { weightedArr << el} } #created weighted array to sample from
			ret << weightedArr.sample #choose one and add it to return val
		}
		
		nGeneral.times {
			weightedArr = []
			els = Element.generalElements
			ret.each { |chosen| els.delete(chosen)} #sample, no replacement of chosen elements
			els.each { |el| el.weight.to_i.times { weightedArr << el} } #created weighted array to sample from
			ret << weightedArr.sample #choose one and add it to return val
		}
		
		#ret.each { |el|  #if element has hardship, move to top
		#	ret.unshift(ret.delete(el)) if el.hasHardship
		#}
		
		return ret
	end
	
	
end
