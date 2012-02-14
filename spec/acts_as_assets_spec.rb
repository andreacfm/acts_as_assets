require "spec_helper"

describe "ActsAsAssets" do

  let(:book) { Book.create!(:title => "my new book") }

  describe "model that acts as assets" do
    subject { Books::Asset.new }
    it { should belong_to(:book) }
    it { should have_attached_file(:asset) }
    it { should have_db_column(:type).of_type(:string) }
    it { should have_db_column(:counter).of_type(:integer).with_options(:default => 0, :null => false) }
    it { should have_db_column(:book_id).of_type(:integer) }
  end

  describe "methods" do
    subject { Books::Assets::TestDoc.new }

    context "given a class of type Books::Assets::TestDoc" do

      describe "root_model" do
        it "should return :book" do
          subject.class.root_model.should eq :book
        end
      end

      describe "acts_as_assets_file_name" do

        it "should return test_doc" do
          b = book
          subject.book_id = b.id
          subject.save!
          subject.send(:acts_as_assets_file_name).should eq 'test_doc'
        end

        it "should append counter number is is greater than 1" do
          b = book
          subject.book_id = b.id
          subject.save!
          subject.counter = 4
          subject.send(:acts_as_assets_file_name).should eq 'test_doc_4'
        end

      end

      describe "acts_as_assets_file_path" do
        it "should return public/system/books/assets" do
          b = book
          subject.book_id = b.id
          subject.save!
          subject.send(:acts_as_assets_file_path).should eq "public/system/books/#{book.id}/assets"
        end
      end

      describe "root_id" do
        it "should return book.id" do
          b = book
          subject.book_id = b.id
          subject.save!
          subject.send(:root_id).should eq b.id
        end
      end

      describe "touch_counter" do

        it "should set counter = 1 by default if counter is actually nil" do
          subject.send :touch_counter
          subject.counter.should eq 1
        end
      end
    end

  end

  context "callbacks" do

    context "before_create" do

      describe "touch_counter" do

        it "should increase counter by one if a document of the same type are created" do
          dc = Books::Assets::TestDoc.create!
          @dtbd << dc
          dc2 = Books::Assets::TestDoc.create!
          @dtbd << dc2
          Books::Asset.find(dc.id).counter.should eq 1
          Books::Asset.find(dc2.id).counter.should eq 2
        end

      end

    end

    context "interpolations" do

      describe "path/url" do

        it "should interpolate the correct path for a subclass instance" do
          b = book
          doc = Books::Assets::TestDoc.create! :asset => jpg_test, :book => b
          @dtbd << doc
          doc.asset.path.should eq "public/system/books/#{b.id}/assets/test_doc.jpg"
        end

        it "should interpolate the correct url for a subclass instance" do
          b = book
          doc = Books::Assets::TestDoc.create! :asset => jpg_test, :book => b
          @dtbd << doc
          doc.asset.url.should  match /\/books\/#{b.id}\/assets\/#{doc.id}/
        end

      end

    end

  end

end
