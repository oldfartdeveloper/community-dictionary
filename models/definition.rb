class Definition < Ohm::Model
  include Ohm::Callbacks
  
  attribute :blurb
  attribute :detail
  counter :score

  reference :term, Term
  reference :user, User
  collection :votes, Vote
  
  after :create, :update_recent
  after :update, :update_recent
  after :delete, :remove_from_recent
  
  def self.recent(recent_count = 10)
    key[:recent].zrevrange(0, recent_count - 1).map(&Definition)
  end
  
  def validate
    assert_present :blurb
    assert_numeric :score
  end
  
  def add_score(by = 1)
    incr(:score, by)
  end
  
  def subtract_score(by = 1)
    decr(:score, by)
  end
  
  def to_hash
    super.merge(:blurb => blurb, :score => score)
  end
  
  def rescore_with_flipped_vote(vote)
    if vote.up_vote?
      add_score(2)
    elsif vote.down_vote?
      subtract_score(2)
    end
  end
  
  def rescore_with_new_vote(vote)
    if vote.up_vote?
      add_score
    elsif vote.down_vote?
      subtract_score
    end
  end
  
  def rescore_with_deleted_vote(vote)
    if vote.up_vote?
      subtract_score
    elsif vote.down_vote?
      add_score
    end
  end
  
  protected
  
  def update_recent
    self.class.key[:recent].zadd(Time.now.to_i, id)
  end
  
  def remove_from_recent
    self.class.key[:recent].zrem(id)
  end
end