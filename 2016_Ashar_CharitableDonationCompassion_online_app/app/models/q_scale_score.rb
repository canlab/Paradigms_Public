class QScaleScore < ActiveRecord::Base
  belongs_to :q_scale
  belongs_to :survey
  belongs_to :target	
end
