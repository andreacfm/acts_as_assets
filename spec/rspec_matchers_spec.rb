require "spec_helper"

describe "Rspec Matchers" do

  context "given a model that acts_as_assets" do
    subject{Books::Asset.new}
    it{should act_as_assets}
  end

  context "given a model that does not acts_as_assets" do
    subject{Book.new}
    it{should_not act_as_assets}
  end

end