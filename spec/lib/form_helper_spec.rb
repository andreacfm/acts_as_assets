# encoding: utf-8
require "spec_helper"
include ActionView::Helpers::FormTagHelper
describe "#model_assets" do
  it "should call all the methods in the array" do
    asset_instances(Book.new, [:assets]).klass.should eq Books::Asset

  end

end