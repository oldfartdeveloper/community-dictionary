require File.dirname(__FILE__) + '/../spec_helper'

describe Definition do
  before(:each) { @definition = Definition.create(:blurb => "spec blurb") }

  describe "serialization" do
    it "should produce the expected json" do
      @definition.to_json.should == "{\"id\":\"1\",\"blurb\":\"spec blurb\",\"score\":0}"
    end
  end
  
  describe "score counter methods" do
    it "should be able to increment a score by 1 by default" do
      lambda { @definition.add_score }.should change{ @definition.score }.by(1)
    end
    
    it "should be able to increment a score by 2" do
      lambda { @definition.add_score(2) }.should change{ @definition.score }.by(2)
    end
    
    it "should be able to decrement a score by 1 by default" do
      lambda { @definition.subtract_score }.should change{ @definition.score }.by(-1)
    end
    
    it "should be able to decrement a score by 2" do
      lambda { @definition.subtract_score(2) }.should change{ @definition.score }.by(-2)
    end
  end
  
  describe "scoring from vote methods" do
    before(:each) do
      @vote = mock(Vote, :up_vote? => false, :down_vote? => false)
    end
    
    it "should increment by 2 when a down vote is getting flipped to an up vote" do
      @vote.should_receive(:down_vote?).and_return(true)
      lambda { @definition.rescore_with_flipped_vote(@vote) }.should change{ @definition.score }.by(2)
    end
        
    it "should decrement by 2 when an up vote is getting flipped to a down vote" do
      @vote.should_receive(:up_vote?).and_return(true)
      lambda { @definition.rescore_with_flipped_vote(@vote) }.should change{ @definition.score }.by(-2)
    end
    
    it "should increment by 1 for a new up vote" do
      @vote.should_receive(:up_vote?).and_return(true)
      lambda { @definition.rescore_with_new_vote(@vote) }.should change{ @definition.score }.by(1)
    end
    
    it "should decrement by 1 for a new down vote" do
      @vote.should_receive(:down_vote?).and_return(true)
      lambda { @definition.rescore_with_new_vote(@vote) }.should change{ @definition.score }.by(-1)
    end

    it "should decrement by 1 when an up vote is deleted" do
      @vote.should_receive(:up_vote?).and_return(true)
      lambda { @definition.rescore_with_deleted_vote(@vote) }.should change{ @definition.score }.by(-1)
    end
    
    it "should increment by 1 when a down vote is deleted" do
      @vote.should_receive(:down_vote?).and_return(true)
      lambda { @definition.rescore_with_deleted_vote(@vote) }.should change{ @definition.score }.by(1)
    end
  end
end