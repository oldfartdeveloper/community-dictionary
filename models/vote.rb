class Vote < Ohm::Model
  include Ohm::Callbacks
  
  attribute :value

  reference :user, User
  reference :definition, Definition
  
  index :value
  
  attr_accessor :vote_flipped, :score_created
  
  def validate
    assert_format :value, /(up|down)/
  end
  
  def self.create_or_update(attributes)
    if vote = Vote.find(:user_id => attributes[:user_id], :definition_id => attributes[:definition_id]).first
      previous_value = vote.value.dup
      vote.value = attributes[:value]
      vote.vote_flipped = vote.value != previous_value
    else
      vote = Vote.new(attributes)
      vote.score_created = true
    end
    vote.save
  end
  
  def up_vote?
    value == "up"
  end
  
  def down_vote?
    ! up_vote?
  end  
  
  protected

  def rescore_as_flip
    definition.rescore_with_flipped_vote(self) if definition
  end
  
  def rescore_as_create
    definition.rescore_with_new_vote(self) if definition
  end
  
  def after_save
    if vote_flipped
      self.vote_flipped = false
      rescore_as_flip
    elsif score_created
      self.score_created = false
      rescore_as_create
    end
  end
  
  def before_delete
    @pre_delete_definition = definition
  end
  
  def after_delete
    @pre_delete_definition.rescore_with_deleted_vote(self)
  end
end