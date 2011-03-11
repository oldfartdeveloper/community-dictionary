class User < Ohm::Model
  attribute :name
  attribute :email
  
  collection :votes, Vote
  collection :definitions, Definition
  
  index :email
  
  def validate
    assert_present :name
    assert_present :email
    assert_unique :email
  end
  
  def to_hash
    super.merge(:name => name)
  end
end