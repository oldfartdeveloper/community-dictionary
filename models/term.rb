class Term < Ohm::Model
  attribute :term
  
  collection :definitions, Definition
  
  index :term
  
  def validate
    assert_unique :term
  end
  
  def add_definition(definition)
    definitions << definition
    definition.term = self
    definition.save
  end
  
  def to_hash
    super.merge(:term => term, :definitions => definitions.all)
  end
end