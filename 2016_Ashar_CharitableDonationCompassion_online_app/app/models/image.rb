class Image < ActiveRecord::Base
  belongs_to :ethnicity
  
  	def url
	  self.file
	end
end
