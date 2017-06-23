class QScale < ActiveRecord::Base
  
  has_many :q_assignments
	has_many :q_scale_scores
	#has_many :q_percentiles
	has_many :q_items, :through => :q_assignments
	belongs_to :q_measure
	
end
