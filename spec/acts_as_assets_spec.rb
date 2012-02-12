require "spec_helper"

describe "ActsAsAssets" do

  let(:book){Book.create!(:title => "my new book")}

  before :all do
    @docs = []
  end

  after :all do
    @docs.each{|d|d.destroy}
  end

  describe "model that acts as assets" do
    subject{Books::Asset.new}
    it { should belong_to(:book)}
    it { should have_attached_file(:asset) }
    it { should have_db_column(:type).of_type(:string) }
    it { should have_db_column(:counter).of_type(:integer).with_options(:default => 0, :null => false) }
    it { should have_db_column(:book_id).of_type(:integer) }
  end

  describe "class methods" do
    subject{Books::Asset.new}
    describe "root_model" do
      context "given a class of type Books::Asset" do
          it "should return :book" do
             subject.class.root_model.should eq :book
          end
      end
    end
  end

  context "callbacks" do

    context "before_create" do

      describe "touch_counter" do

        it "should set counter = 1 by default if counter is actually nil" do
          doc = Books::Assets::Image.new
          doc.send :touch_counter
          doc.counter.should eq 1
        end

        it "should increase counter by one if a document of the same type are created" do
          dc = Books::Assets::Image.create!
          @docs << dc
          dc2 = Books::Assets::Image.create!
          @docs << dc2
          Books::Asset.find(dc.id).counter.should eq 1
          Books::Asset.find(dc2.id).counter.should eq 2
        end

      end

    end

    context "interpolations" do

      describe "path/url" do

        it "should interpolate the correct path for a subclass instance" do
          book
          doc = Books::Assets::Image.create! :asset => jpg_test, :book => book
          @docs << doc
          doc.asset.path.should eq "public/system/books/#{book.id}/assets//fv_#{book.id}_test_jpg.jpg"
        end

        it "should interpolate the correct url for a subclass instance" do
          permesso = pratica.permesso_urbanistico
          doc = Pratiche::PermessiUrbanistici::Documenti::TestDoc.create! :documento => pdf_test_file, :permesso_urbanistico => permesso
          doc.documento.url.should match(/\/documents\/pratiche\/#{pratica.id}\/permessi_urbanistici\/#{doc.id}/)
          doc.destroy
        end

      end

    end

  end

end
