require File.dirname(__FILE__) + '/../spec_helper'

require "digest/md5"

describe User do
  def valid_attributes
    {
      :name => Faker::Name.name,
      :email => Faker::Internet.email
    }
  end
  
  let(:user) { @user ||= User.new(valid_attributes) }
  
  describe "validations" do
    it "require a name" do
      user = User.new(valid_attributes.merge(:name => nil))
      user.should_not be_valid
    end
    
    it "require an email" do
      user = User.new(valid_attributes.merge(:email => nil))
      user.should_not be_valid
    end
    
    it "requires an email to be unique" do
      user.save
      user.should be_valid
      dupe_email_user = User.new(valid_attributes.merge(:email => user.email))
      dupe_email_user.should_not be_valid
    end
  end
  
  describe "setting the password" do
    it "should store a random salt for use with hashing" do
      user.password = "foobar"
      user.password_confirmation = "foobar"
      user.save
      user.password_salt.should_not be_nil
    end
        
    it "should raise an error if the password and confirmation don't match" do
      user.password = "foobar"
      user.password_confirmation = "barfoo"
      lambda { user.save }.should raise_error
    end
    
    it "should hash the password into the password hash_attribute" do
      user.password = "foobar"
      user.password_confirmation = "foobar"
      user.save
      user.hashed_password.should_not be_nil
      Digest::SHA1.hexdigest([user.password_salt, "foobar"].join(':')).should == user.hashed_password
    end
  end
  
  describe "checking the password" do
    before(:each) do
      user.password = "password"
      user.password_confirmation = "password"
      user.save
    end
    
    it "should return true if the password matches" do
      user.check_password("password").should be_true
    end
  end
end