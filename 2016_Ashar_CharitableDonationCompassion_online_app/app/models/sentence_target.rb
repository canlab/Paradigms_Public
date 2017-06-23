class SentenceTarget < ActiveRecord::Base
  belongs_to :sentence
  belongs_to :target
end
