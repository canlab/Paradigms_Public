class Donation < ActiveRecord::Base
  belongs_to :session
  belongs_to :hardship
end
