require "spec_helper"

describe Books::AssetsController do

  it {should route(:get,'books/1/assets/TestDoc').to(
                 :controller => "books/assets", :action => :index, :fk_name => 1, :type => "TestDoc")}

  it {should route(:get,'books/1/assets/my/asset/type').to(
                 :controller => "books/assets", :action => :index, :fk_name => 1, :type => "my/asset/type")}

  it {should route(:post,'books/1/assets/TestDoc.js').to(
                 :controller => "books/assets", :action => :create, :fk_name => 1, :type => "TestDoc", :format => 'js')}

  it {should route(:delete,'books/1/assets/20.js').to(
                 :controller => "books/assets", :action => :destroy, :fk_name => 1, :format => 'js', :asset_id => 20)}

  it {should route(:get,'books/1/assets/get/20/thumb/filename.gif').to(
                 :controller => "books/assets", :action => :get, :fk_name => 1, :style => "thumb", :asset_id => 20, :filename => "filename", :extension => "gif" )}

  it {should route(:get,'books/1/assets/get/20/filename.gif').to(
                 :controller => "books/assets", :action => :get, :fk_name => 1, :asset_id => 20, :filename => "filename", :extension => "gif")}

end

describe TipiPannello::AssetsController do
  it {should route(:delete,'tipi_pannello/il_mio_tipo/assets/20.js').to(
                 :controller => "tipi_pannello/assets", :action => :destroy, :fk_name=> 'il_mio_tipo', :format => 'js', :asset_id => 20)}

end