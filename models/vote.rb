class Vote < Ohm::Model
  include Ohm::Callbacks
  
  attribute :value

  reference :user, User
  reference :definition, Definition
  
  index :value
  
  after :save, :handle_save_scoring
  before :delete, :stash_definition
  after :delete, :notify_definition_vote_deleted
  
  attr_accessor :vote_flipped, :score_as_new
  
  def validate
    assert_format :value, /(up|down)/
  end
  
  def self.create_or_update(attributes)
    if vote = Vote.find(:user_id => attributes[:user_id], :definition_id => attributes[:definition_id]).first
      previous_value = vote.value
      vote.value = attributes[:value]
      vote.vote_flipped = vote.value != previous_value
    else
      vote = Vote.new(attributes)
      vote.score_as_new = true
    end
    vote.save
  end
  
  def up_vote?
    value == "up"
  end
  
  def down_vote?
    ! up_vote?
  end
  
  def to_hash
    super.merge(:user => user, :definition => definition)
  end
  
  protected

  def handle_save_scoring
    if vote_flipped
      self.vote_flipped = false
      notify_definition_vote_flip
    elsif score_as_new
      self.score_as_new = false
      notify_definition_new_vote
    end
  end
  
  def notify_definition_vote_flip
    definition.vote_flip(self) if definition
  end
  
  def notify_definition_new_vote
    definition.new_vote(self) if definition
  end
  
  def stash_definition
    @pre_delete_definition = definition
  end
  
  def notify_definition_vote_deleted
    @pre_delete_definition.rescore_with_deleted_vote(self)
  end
end