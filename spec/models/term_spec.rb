require File.dirname(__FILE__) + '/../spec_helper'

describe Term do
  before(:each) { @term = Term.create(:term => "foobar") }

  it "requires a term" do
    @term.term = nil
    @term.should_not be_valid
  end
  
  it "requires a unique term" do
    dupe_term = Term.new(:term => @term.term)
    dupe_term.should_not be_valid
  end
  
  describe "adding a definition" do
    # I can't figure out how to mock here without over-implmenting.
    # Just difficult or, a smell?
    before(:each) { @definition = Definition.create(:blurb => "foobar blurb") }
    
    it "should add the passed definition to its set" do
      @term.add_definition(@definition)
    end
    
    it "associate the definition with the term" do
      @term.add_definition(@definition)
      @definition.term.should == @term
    end
    
  end

  describe "serialization" do
    it "should produce the expected json" do
      @term.to_json.should == "{\"id\":\"1\",\"term\":\"foobar\",\"definitions\":[]}"
    end
  end
  
  describe "finding undefined terms" do
    it "should find terms with empty definition collections" do
      term_fizz = Term.create(:term => "fizz")
      term_buzz = Term.create(:term => "buzz")
      @term.add_definition(Definition.create(:blurb => "a term programmers like"))
      
      Term.undefined_terms.should include(term_fizz)
      Term.undefined_terms.should include(term_buzz)
      Term.undefined_terms.should_not include(@term)
    end
  end
end