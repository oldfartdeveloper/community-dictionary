class Vote < Ohm::Model
  include Ohm::Callbacks
  
  attribute :value

  reference :user, User
  reference :definition, Definition
  
  index :value
  
  def validates
    assert_format :value, /(up|down)/
  end
  
  def self.create_or_update(attributes)
    if vote = Vote.find(:user_id => attributes[:user_id], :definition_id => attributes[:definition_id]).first
      vote.definition.rescore_with_flipped_vote(vote) unless vote.value == attributes[:value]
      vote.value = attributes[:value]
    else
      vote = Vote.create(attributes)
      vote.definition.rescore_with_new_vote(vote)
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
  
  def before_delete
    @pre_delete_definition = definition
  end
  
  def after_delete
    @pre_delete_definition.rescore_with_deleted_vote(self)
  end
end