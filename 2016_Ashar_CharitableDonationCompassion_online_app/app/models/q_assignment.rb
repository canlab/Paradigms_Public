class QAssignment < ActiveRecord::Base
  
  belongs_to :q_item
  belongs_to :q_scale
  belongs_to :q_measure
  
end
