class Survey < ActiveRecord::Base
  
  # The data hash contains:
  # * measures: numerical IDs of all measures to administer
  # * current_measure: numerical ID of currently selected measure
  # * items: IDs of all remaining items in the current measure (except active ones)
  # * active_items: IDs of items to be presented on the current screen
  serialize :data, Hash
  belongs_to :session
  has_many :q_item_scores
  has_many :q_scale_scores
  has_many :targets
  has_one :demographic
  
  #validates_presence_of :occasion_id, :study_id, :user_id
  #validate_on_create :validate_login
  
  # Return next N items
  def get_items(n=20)
    @data = self.data
    # Initialize data
    if @data.nil?  
      @data = { :measures => self.study.q_measure_ids, :active_items => [] }  
      @data[:measures].shuffle! if self.study.rand_measures
    end
    
    return QItem.find(@data[:active_items]) if !@data[:active_items].empty?
    load_measure if @data[:current_measure].nil? or @data[:items].empty?
    select_items = @data[:items].slice!(0,n)
    @data[:active_items] = select_items
    items = QItem.find(select_items)
    items.shuffle! if self.study.rand_items
    self.data = @data
    items if self.save!
  end
  
  # Load items for the next measure
  def load_measure
    @data[:current_measure] = @data[:measures].shift
    items = QMeasure.find(@data[:current_measure]).q_items.map { |i| i.id }.uniq
    p items
    items.shuffle! if self.study.rand_items # randomize items
    p items
    @data[:items] = items
    @data[:item_num] = 0
  end
  
  # Check if there are sitems/measures remaining
  def has_more?
    data = self.data
    !data[:items].empty? or !data[:measures].empty?
  end
  
  # Save items from last screen
  def save_items(items, target_info)
	
	data = self.data
	new_scores = []
    items.each { |i, vals|
#      next if !data[:active_items].include?(vals[:q_item_id].to_i)
#      data[:item_num] += 1
#      data[:active_items].delete(vals[:q_item_id].to_i)
      next if (vals[:response].nil? or vals[:response] == '') and (vals[:text].nil? or vals[:text] == '')

	  new_score = QItemScore.new(vals.merge({:survey_id => self.id}))

	  #add target info, if its a target
	  new_score.target = target_info if target_info.kind_of?(Target)	  
      new_scores << new_score
    }
    
    self.q_item_scores << new_scores
 	score_target(new_scores, target_info) if target_info.kind_of?(Target)
 	
    self.save!
  end
  
  def score_target(new_scores, target_info)
      
      item_scores = {}
	  new_scores.each { |i| item_scores[i.q_item_id] = i.response }
	  
	  m = QMeasure.targ_measure     
      n_opt = m.anchors.split('/').size
      m.q_scales.each { |s|
        n_items = s.q_assignments.size
        n_answered = 0
        score = 0.0
        s.q_assignments.each { |a|
          next if !item_scores.key?(a.q_item_id)
          p "Scoring Item ======== " +  item_scores[a.q_item_id].to_s + '     ' + a.q_item_id.to_s
          resp = item_scores[a.q_item_id]
          resp = n_opt + 1 - resp if a.keying < 0
          score += resp
          n_answered += 1
        }
        
        score = n_answered.zero? ? nil : score * n_items / n_answered
        
        new_scale = QScaleScore.new(:q_scale_id => s.id, :score => score, :n_answered => n_answered, :target => target_info)
        self.q_scale_scores << new_scale
      }
    
      self.save!      
  end
  

  # Score all measures/scales
  def score
    
    # Make item_id => score hash
    item_scores = {}
    self.q_item_scores.each { |i| item_scores[i.q_item_id] = i.response }
    
    measures = QMeasure.measures
    measures.each { |m|
    
    
    p 'Scoring Measure ' + m.name
    
      # For now, we can't score measures without fixed number of anchors. Eventually,
      # we could add item-based summation, though virtually no measures require this.
      # Just need to make sure to specify number of anchors in measures that are going
      # to be scored!
      next if m.anchors.nil?
      n_opt = m.anchors.split('/').size
      m.q_scales.each { |s|
        n_items = s.q_assignments.size
        n_answered = 0
        score = 0.0
        s.q_assignments.each { |a|
          next if !item_scores.key?(a.q_item_id)
          p "Scoring Item ======== " +  item_scores[a.q_item_id].to_s + '     ' + a.q_item_id.to_s
          resp = item_scores[a.q_item_id]
          resp = n_opt + 1 - resp if a.keying < 0
          score += resp
          n_answered += 1
        }
        score = n_answered.zero? ? nil : score * n_items / n_answered
        self.q_scale_scores << QScaleScore.new(:q_scale_id => s.id, :score => score, :n_answered => n_answered)
      }
    }
    self.save!
  end


  def current_measure
    QMeasure.find(self.data[:current_measure])
  end
  
  def item_num
    self.data[:item_num]
  end
=begin  
  # Additional validation when initialized
  def validate_login
    # occ, study, user = Occasion.find(self.occasion_id), Study.find(self.study_id), 
    errors.add_to_base "Invalid occasion ID." unless self.occasion
    if self.study
      errors.add_to_base "Occasion and study do not match." unless self.study.has_occasion?(self.occasion)
    else
      errors.add_to_base "Invalid study code." unless self.study
    end
    if self.user
      errors.add_to_base "The specified experimenter has no access to that study." unless self.user.can_access?(self.study)
    else
      errors.add_to_base "Invalid user code." unless self.user
    end  
  end
=end
end
