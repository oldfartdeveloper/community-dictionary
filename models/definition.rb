class Definition < Ohm::Model
  reference :term, Term
  attribute :blurb
  attribute :detail
  counter :votes
  
  def validate
    assert_present :blurb
  end
  
  def add_vote(by = 1)
    incr(:votes, by)
  end
  
  def subtract_vote(by = 1)
    decr(:votes, by)
  end
  
  def to_hash
    super.merge(:blurb => blurb)
  end
end