require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  def valid_attributes
    {
      :name => Faker::Name.name,
      :email => Faker::Internet.email
    }
  end
  
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
      user = User.create(valid_attributes)
      user.should be_valid
      dupe_email_user = User.new(valid_attributes.merge(:email => user.email))
      dupe_email_user.should_not be_valid
    end
  end
end