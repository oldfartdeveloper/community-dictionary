require File.dirname(__FILE__) + '/../spec_helper'

describe Vote do
  before(:each) do
    @vote = Vote.create(:value => 'up', :definition_id => 1)
  end
  
  describe "validating the value" do
    it "should require up or down" do
      @vote.value = "down"
      @vote.should be_valid
      @vote.value = "up"
      @vote.should be_valid
      @vote.value = "bogus"
      @vote.should_not be_valid
    end
    
  end

  it "should be an upvote if the value is 'up'" do
    @vote.value = "up"
    @vote.should be_up_vote
  end
  
  it "should be a downvote if the value is 'down'" do
    @vote.value = "down"
    @vote.should be_down_vote
  end
  
  it "should tell the associated definition to rescore after it's deleted" do
    definition = mock(Definition)
    @vote.stub(:definition).and_return(definition)
    definition.should_receive(:rescore_with_deleted_vote).with(@vote)
    @vote.delete
  end
  
  describe "creating or updating a vote" do
    context "where the user has already voted" do
      it "should set the value of the existing vote to the new value" do
        Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'up')
        Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'down')

        Vote.find(:user_id => 3, :definition_id => 5, :value => 'up').should be_empty
        Vote.find(:user_id => 3, :definition_id => 5, :value => 'down').should_not be_empty
      end
      
      it "should rescore as a flipped vote if the value changed" do
        vote = Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'up')
        vote.stub(:definition).and_return(mock(Definition))
        Vote.should_receive(:find).and_return([vote])
        vote.definition.should_receive(:vote_flip).with(vote)
        Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'down')
      end
      
      it "should not rescore as a flipped vote if the value didn't change" do
        vote = Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'up')
        vote.stub(:definition).and_return(mock(Definition))
        Vote.should_receive(:find).and_return([vote])
        vote.definition.should_not_receive(:vote_flip)
        Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'up')
      end
    end
    
    context "where the user is creating a new vote" do
      it "should create a new vote with the passed attributes" do
        Vote.create_or_update(:user_id => 3, :definition_id => 5, :value => 'up')
        Vote.find(:user_id => 3, :definition_id => 5, :value => 'up').should_not be_empty
      end
      
      it "should tell the associated definition to rescore with the new vote" do
        definition = mock(Definition)
        @vote.stub(:definition).and_return(definition) 
        Vote.should_receive(:new).and_return(@vote)
        definition.should_receive(:new_vote).with(@vote)
        Vote.create_or_update(:user_id => 3, :definition_id => 1, :value => 'up')
      end
    end
  end
end