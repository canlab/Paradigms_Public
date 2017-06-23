class Sentence < ActiveRecord::Base
	belongs_to :element
	belongs_to :hardship
	
	has_many :sentence_targets
	has_many :targets, :through => :sentence_targets
	
	#return a formatted string: first letter capitalzed, ends with period.
	#male: true if masculine
	def formatted(male)		
		Sentence.formatted(text,male)
	end
	
	def self.formatted(string, male)
		t = string.strip
		if !male
			#match mid-sentence or at beginning or end, depending on word
			t.gsub!(/\she\s/i, ' she ')
			t.gsub!(/^he\s/i, 'she ')
			t.gsub!(/\shis\s/i, ' her ')
			t.gsub!(/^his\s/i, 'her ')
			t.gsub!(/\shim\s/i, ' her ')
			t.gsub!(/\shim$/i, ' her')
		end
	
		t[0] = t[0].capitalize
		t = t + '.' if !t.ends_with?('.')
		return t
	end
end
