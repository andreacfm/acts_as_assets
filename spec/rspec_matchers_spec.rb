require "spec_helper"

describe "Rspec Matchers" do

  describe "act_as_asset" do
    context "given a model that acts_as_assets" do
      subject{Books::Asset.new}
      it{should act_as_assets}
    end

    context "given a model that does not acts_as_assets" do
      subject{Book.new}
      it{should_not act_as_assets}
    end
  end

  describe "act_as_unique_asset" do
    context "given a model that include unique asset" do
      subject{Books::Assets::UniqueTestDoc.new}
      it{should act_as_unique_asset}
    end

    context "given a model that does not include module unique asset" do
      subject{Books::Assets::TestDoc.new}
      it{should_not act_as_unique_asset}
    end
  end

end