require "spec_helper"

describe Books::AssetsController do
  render_views
  let(:book) { Book.create!(:title => "my new book") }
  let(:target){'target_div'}

  before :all do
    @docs = []
  end

  after :all do
    @docs.each { |d| d.destroy }
  end


  context "given a Books::AssetsController controller " do

    describe "root_model_name" do
      it "should return book" do
        subject.send(:root_model_name).should eq 'book'
      end
    end

    describe "destroy_path" do
      before do
        @book = book
        @asset = Books::Assets::TestDoc.create!(:book => @book, :asset => jpg_test)
        @docs << @asset
        get :index, :book_id => @book.id, :type => "Assets/TestDoc"
      end
      it "should return /books/id/assets/asset_id" do
        subject.send(:destroy_path,@asset, target).should eq "/books/#{@book.id}/assets/#{@asset.id}?target=#{target}"
      end
    end

  end

  context "filters" do

    context "assign_root_model" do

      before do
        @book = book
        get :index, :book_id => @book.id, :type => "Assets/TestDoc"
      end

      it "should assign @book" do
        subject.assign_to(:book)
        assigns(:book).id.should eq @book.id
      end
    end

  end

  describe "index" do

    context "format html" do

      before :each do
        @book = book
        @asset = Books::Assets::TestDoc.create!(:book => @book, :asset => jpg_test)
        @docs << @asset
        get :index, :book_id => book.id, :type => "Assets/TestDoc", :target => target, :format => :html
      end

      it "should assign variables" do
        should assign_to(:assets)
        should assign_to(:target)
        should assign_to(:book)
      end

      it{should respond_with(:success)}

      it{should render_template('acts_as_assets/assets/index')}

      it "should return the correct formatted view" do
        response.body.should match(/#{@asset.asset.to_file.original_filename}/)
      end

    end

    context "format json" do

      before :each do
        @book = book
        @asset = Books::Assets::TestDoc.create!(:book => @book, :asset => jpg_test)
        @docs << @asset
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
      @book = book
      post :create, :book_id => @book.id, :type => "Assets/TestDoc", :file => jpg_test, :format => "js"
      @docs << assigns(:asset)
    end

    it "should assign variables" do
      should assign_to(:asset)
      should assign_to(:book)
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
      @book = book
      @asset = Books::Assets::TestDoc.create!(:book => @book, :asset => jpg_test)
      delete :destroy, :book_id => @book.id, :asset_id => @asset.id, :format => "js", :target => target
    end

    it "should assign variables" do
      should assign_to(:asset)
      should assign_to(:target)
      should assign_to(:book)
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




end