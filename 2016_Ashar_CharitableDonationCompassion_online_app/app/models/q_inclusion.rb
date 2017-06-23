class QInclusion < ActiveRecord::Base
  
  belongs_to :q_measure
  belongs_to :study
  
end
