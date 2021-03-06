require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe BLM do
  context "reading a .blm file" do
  	before :all do
  		@blm = BLM::Document.new( File.open(File.dirname(__FILE__) + "/blm/example_data.blm", "r").read )
  	end
  	
  	it "should parse settings from the header" do
  		@blm.header.should be_a(Hash)
  		@blm.header[:version].should_not be_nil
  		@blm.header[:eof].should_not be_nil
  		@blm.header[:eor].should_not be_nil
  	end
  	
  	it "should parse the column definition" do
  		@blm.definition.should be_a(Array)
  		@blm.definition.should have_at_least(1).items
  	end
  	
  	it "should parse the data into an array of hashes" do
  		@blm.data.should be_a(Array)
  		@blm.data.should have_at_least(1).items
  		@blm.data.should respond_to(:each, :each_with_index)
  		@blm.data.each do |row|
  			row.should be_a(BLM::Row)
  		end
  	end
  	
  	it "should allow access to data values via methods" do
  		@blm.data.each do |row|
  			row.address_1.should_not be_nil
  		end
  	end
  	
  	it "should allow access to the @attributes hash directly" do
  		@blm.data.each do |row|
  			row.attributes.should be_a(Hash)
  		end
  	end
  end
end
