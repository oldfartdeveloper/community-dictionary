class Term < Ohm::Model
  attribute :term
  
  collection :definitions, Definition
  
  index :term
  
  def self.undefined_terms
    # This is likely not very efficient.  Find a faster way.
    all.select { |term| term.definitions.empty? }
  end
  
  def validate
    assert_present :term
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