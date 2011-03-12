class User < Ohm::Model
  include Ohm::Callbacks
  
  attribute :name
  attribute :email
  attribute :password_salt
  attribute :hashed_password
  
  collection :votes, Vote
  collection :definitions, Definition
  
  index :email
  
  attr_accessor :password, :password_confirmation
  
  def validate
    assert_present :name
    assert_present :email
    assert_unique :email
  end
  
  def to_hash
    super.merge(:name => name)
  end
  
  def check_password(plaintext_password)
    hash_plaintext_password(plaintext_password) == hashed_password
  end
  
  protected
  
  def hash_plaintext_password(plaintext_password)
    Digest::SHA1.hexdigest([password_salt, plaintext_password].join(':'))
  end
  
  def before_save
    return unless password =~ /\S+/ || password_confirmation =~ /\S+/

    if password == password_confirmation
      self.password_salt = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
      self.hashed_password = hash_plaintext_password(password)
    else
      raise "Password and confirmation don't match."
    end
  end
end