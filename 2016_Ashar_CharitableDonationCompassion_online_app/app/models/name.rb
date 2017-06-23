class Name < ActiveRecord::Base
	def get_one_ethnicity
		ethnicity[rand(ethnicity.length)]
	end
			
	def self.find_all_by_ethnicity(char_code)
		arr = []
		char_code.each_char { |char|
			char.capitalize!
			arr.concat Name.where("ethnicity like ?", "%#{char}%")
		}
		arr.uniq
	end
	
	def self.find_by_ethnicity_and_gender(eth, gender)
		Name.where("ethnicity like ? and gender = ?", "%#{eth.code}%", gender).sample
	end
	
end
