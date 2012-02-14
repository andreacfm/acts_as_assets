require "spec_helper"

describe ActsAsAssets::UniqueAsset do
  let(:book) { Book.create!(:title => "my new book") }

  context "creating 2 assets of the same type related to the same resource" do
    before do
      @book = book
    end

    context "and asset include the model UniqAsset" do

      it "should fail on the creation of the second asset" do
        asset1 = Books::Assets::UniqueTestDoc.create! :book => @book
        @dtbd << asset1
        asset2 = Books::Assets::UniqueTestDoc.new :book => @book
        @dtbd << asset2
        asset2.save

        asset2.should_not be_valid
        asset2.should have(1).error_on("Books::Assets::UniqueTestDoc")
      end

    end

    context "and asset does not include the model UniqAsset" do

      it "should fail on the creation of the second asset" do
        asset1 = Books::Assets::TestDoc.create! :book => @book
        @dtbd << asset1
        asset2 = Books::Assets::TestDoc.new :book => @book
        @dtbd << asset2
        asset2.save

        asset2.should be_valid
        asset2.should have(0).error_on("Books::Assets::UniqueTestDoc")
      end

    end

  end

end