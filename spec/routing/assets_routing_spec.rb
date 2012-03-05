require "spec_helper"

describe Books::AssetsController do

  it {should route(:get,'books/1/assets/TestDoc').to(
                 :controller => "books/assets", :action => :index, :book_id => 1, :type => "TestDoc")}

  it {should route(:get,'books/1/assets/my/asset/type').to(
                 :controller => "books/assets", :action => :index, :book_id => 1, :type => "my/asset/type")}

  it {should route(:post,'books/1/assets/TestDoc.js').to(
                 :controller => "books/assets", :action => :create, :book_id => 1, :type => "TestDoc", :format => 'js')}

  it {should route(:delete,'books/1/assets/20.js').to(
                 :controller => "books/assets", :action => :destroy, :book_id => 1, :format => 'js', :asset_id => 20)}

  it {should route(:get,'books/1/assets/get/thumb/20').to(
                 :controller => "books/assets", :action => :get, :book_id => 1, :style => "thumb", :asset_id => 20)}

  it {should route(:get,'books/1/assets/get/20').to(
                 :controller => "books/assets", :action => :get, :book_id => 1, :asset_id => 20)}

end