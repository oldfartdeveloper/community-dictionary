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
    
    it "should increment by 2 for an up vote that was a down vote" do
      @vote.should_receive(:up_vote?).and_return(true)
      lambda { @definition.rescore_with_flipped_vote(@vote) }.should change{ @definition.score }.by(2)
    end
        
    it "should decrement by 2 when an up vote is getting flipped to a down vote" do
      @vote.should_receive(:down_vote?).and_return(true)
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
  
  describe "to track recent updates it" do
    it "should add to a zset Term:#id:definitions" do
      @definition.save
      Definition.key[:recent].zrange(0, -1).should include(@definition.id)
    end
    
    it "should score the zset entry with epoch seconds" do
      frozen_time = Time.now + 3600
      Timecop.freeze(frozen_time) do
        @definition.save
        Definition.key[:recent].zscore(@definition.id).to_i.should == frozen_time.to_i
      end
    end
    
    it "should be removed from the zset after it is deleted" do
      @definition.save
      @definition.delete
      Definition.key[:recent].zrange(0, -1).should_not include(@definition.id)
    end
  end
  
  describe "finding recently updated terms" do
    before(:each) do
      Definition.all.map(&:delete)
      oldest_def = Timecop.freeze(Time.now - 300) { Definition.create(:blurb => "oldest") }
      middle_def = Timecop.freeze(Time.now - 200) { Definition.create(:blurb => "middle") }
      latest_def = Timecop.freeze(Time.now - 100) { Definition.create(:blurb => "latest") }
    end
    
    it "should find definitions in descending order or update" do      
      Definition.recent.map(&:blurb).should == ["latest", "middle", "oldest"]
    end
    
    it "should allow setting the max number of definitions to return" do
      Definition.recent(2).map(&:blurb).should == ["latest", "middle"]
    end
  end
end