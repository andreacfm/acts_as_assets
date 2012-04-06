# encoding: utf-8
require "spec_helper"
require "base64"

describe Books::AssetsController do
  render_views
  let(:book) { Book.create!(:title => "my new book") }
  let(:target){'target_div'}

  context "given a Books::AssetsController controller " do
    describe "destroy_path" do
      before do
        @asset = Books::Assets::TestDoc.create!(:book => book, :asset => uploaded_test_asset)
        get :index, :book_id => book.id, :type => "Assets/TestDoc"
      end

      it "should return /books/id/assets/asset_id" do
        subject.send(:destroy_path, @asset, target).should eq "/books/#{book.id}/assets/#{@asset.id}?target=#{target}"
      end
    end

  end

  context "filters" do

    context "load_model" do
      before do
        get :index, :book_id => book.id, :type => "Assets/TestDoc"
      end

      it "should assign @book" do
        subject.assign_to(:book)
        assigns(:model).id.should eq book.id
      end
    end

  end

  describe "index" do

    context "format html" do

      before :each do
        @asset = Books::Assets::TestDoc.create!(:book => book, :asset => uploaded_test_asset)
        get :index, :book_id => book.id, :type => "Assets/TestDoc", :target => target, :format => :html
      end

      it "should assign variables" do
        should assign_to(:assets)
        should assign_to(:target)
        should assign_to(:model)
      end

      it{should respond_with(:success)}

      it{should render_template('acts_as_assets/assets/index')}

      it "should return the correct formatted view" do
        response.body.should match(/#{@asset.asset.to_file.original_filename}/)
      end

    end

    context "format json" do

      before :each do
        @asset = Books::Assets::TestDoc.create!(:book => book, :asset => uploaded_test_asset)
        get :index, :book_id => book.id, :type => "Assets/TestDoc", :target => target, :format => :json
      end

      it{should_not render_template('acts_as_assets/assets/index')}

      it "should return assets in json format" do
        ActiveSupport::JSON.decode(response.body).first["asset_file_name"].should eq @asset.asset_file_name
      end

    end

  end

  describe "create" do

    before do
      post :create, :book_id => book.id, :type => "Assets/TestDoc", :file => uploaded_test_asset, :format => "js"
    end

    it "should assign variables" do
      should assign_to(:asset)
      should assign_to(:model)
    end

    it "should save the correct content_type" do
      assigns(:asset).asset.content_type.should == "image/jpeg"
    end

    it "should be success returning the correct json formatted text and the correct content type" do
      ActiveSupport::JSON.decode(response.body)["success"].should be_true
      should respond_with_content_type(:js)
      should respond_with(:success)
    end

    it "should correctly save the file" do
      File.exist?(File.expand_path(assigns(:asset).asset.path)).should be_true
    end

  end

  describe "destroy" do

    before :each do
      @asset = Books::Assets::TestDoc.create!(:book => book, :asset => uploaded_test_asset)
      delete :destroy, :book_id => book.id, :type => "Assets/TestDoc", :asset_id => @asset.id, :format => "js", :target => target
    end

    it "should assign variables" do
      should assign_to(:asset)
      should assign_to(:target)
      should assign_to(:model)
    end

    it "should be success returning the correct content type and a json string reporting succes == true" do
      ActiveSupport::JSON.decode(response.body)["success"].should be_true
      should respond_with_content_type(:js)
      should respond_with(:success)
    end

    it{should render_template('acts_as_assets/assets/destroy')}

    it "should correctly delete the file" do
      File.exist?(File.expand_path(@asset.asset.path)).should be_false
    end

  end

  describe "get" do

    describe "sending existing file without style" do
      before  do
        @asset = Books::Assets::TestDoc.create!(:book => book, :asset => uploaded_test_asset)
        get :get, :book_id => book.id, :asset_id => @asset.id, :type => "Assets/TestDoc"
      end

      it "should stream the asset" do
        should respond_with(:success)
        should respond_with_content_type("image/jpeg")
        response.headers.to_s.should match /#{assigns(:asset).asset.to_file.original_filename}/
      end

    end

    describe "sending existing file with a required style" do
      before  do
        @asset = Books::Assets::TestImage.create! :asset => uploaded_test_asset, :book => book
        get :get, :book_id => book.id, :asset_id => @asset.id, :style => "thumb", :type => "Assets/TestDoc"
      end

      it "should assign path" do
        should assign_to(:path)
        assigns(:path).should match /thumb/
      end

      it "should stream the asset" do
        should respond_with(:success)
        should respond_with_content_type("image/jpeg")
        dir = "#{File.dirname(__FILE__)}/../temp"
        open("#{dir}/test.jpg", "wb") { |file|
          file.write(response.body)
        }
        Paperclip::Geometry.from_file(File.expand_path("#{dir}/test.jpg")).to_s.should match /64/
      end

    end

    describe "when requiring a file that does not exists" do
      before  do
        get :get, :book_id => book.id, :asset_id => 123456789,:type => "Assets/TestDoc"
      end

      it "should return 404 and attempt to render custom rails 404.html static file" do
        should respond_with(404)
      end
    end
  end
end