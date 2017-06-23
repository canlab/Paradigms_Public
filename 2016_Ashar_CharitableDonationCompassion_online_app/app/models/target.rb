class Target < ActiveRecord::Base
  belongs_to :image
  belongs_to :hardship
  belongs_to :name
  belongs_to :survey
  has_many :sentence_targets
  has_many :sentences, :through => :sentence_targets
  has_many :q_item_scores
  has_many :q_scale_scores
end
