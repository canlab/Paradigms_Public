class QItem < ActiveRecord::Base
  
  has_many :q_assignments
	has_many :q_scales, :through => :q_assignments
	has_many :q_measures, :through => :q_assignments
	has_many :q_item_scores
  
end
