require "spec_helper"

describe "ActsAsAssets" do

  let(:book) { Book.create!(:title => "my new book") }
  let(:chap) { Chapter.create!(:id => "a new chapter") }
  let(:suntech) {TipoPannello.create!(:id=>'Suntech STP')}

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

      describe "definitions" do
        it "should not include styles" do
          subject.class.attachment_definitions[:asset].should_not include(:styles)
        end
        it "should include correct url" do
          subject.class.attachment_definitions[:asset][:url].should == "/books/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:acts_as_assets_file_name.:extension"
        end
        it "should include correct path" do
          subject.class.attachment_definitions[:asset][:path].should == ":acts_as_assets_file_path/:acts_as_assets_file_name.:extension"
        end
      end

      describe "model_sym" do
        specify { subject.class.base_model_sym.should eq :book }
      end

      describe "acts_as_assets_file_name" do

        it "should return test_doc" do
          subject.book_id = book.id
          subject.save!
          subject.send(:acts_as_assets_file_name).should eq 'test_doc'
        end

        it "should append counter number is is greater than 1" do
          subject.book_id = book.id
          subject.save!
          subject.counter = 4
          subject.send(:acts_as_assets_file_name).should eq 'test_doc_4'
        end
      end

      describe "acts_as_assets_file_path" do
        it "should return public/system/books/assets" do
          subject.book_id = book.id
          subject.save!
          subject.send(:acts_as_assets_file_path).should eq "public/system/books/#{book.id}/assets"
        end
        it "should check file path for natural keys" do
          t = TipiPannello::Documenti::SchedaTecnica.create!(:tipo_pannello => suntech, :asset => uploaded_test_asset)
          t.send(:acts_as_assets_file_path).should eq "public/system/tipi_pannello/Suntech STP/documenti"
        end
      end

      describe "foreign_key_value" do
        it "should return book.id" do
          subject.book_id = book.id
          subject.save!
          subject.send(:foreign_key_value).should eq book.id
        end
      end

      describe "touch_counter" do

        it "should set counter = 1 by default if counter is actually nil" do
          subject.send :increment_counter
          subject.counter.should eq 1
        end
      end
    end

  end

  context "callbacks" do

    context "before_create" do
      describe "increment_counter" do
        it "should increase counter by one if a document of the same type are created" do
          dc = Books::Assets::TestDoc.create!
          dc2 = Books::Assets::TestDoc.create!
          Books::Asset.find(dc.id).counter.should eq 1
          Books::Asset.find(dc2.id).counter.should eq 2
        end
      end
    end

    context "interpolations" do
      describe "path/url" do
        it "should interpolate the correct path for a subclass instance" do
          doc = Books::Assets::TestDoc.create! :asset => uploaded_test_asset, :book => book
          doc.asset.path.should eq "public/system/books/#{book.id}/assets/test_doc.jpg"
        end
        it "should interpolate the correct url for a subclass instance" do
          doc = Books::Assets::TestDoc.create! :asset => uploaded_test_asset, :book => book
          doc.asset.url.should match /\/books\/#{book.id}\/assets\/get\/#{doc.id}\/#{doc.asset.to_file.original_filename}/
        end
        it "should interpolate the correct path for a subclass instance" do
          chapter = Chapters::Assets::Paragraph.create!(:chapter => chap, :asset => uploaded_test_asset)
          chapter.asset.path.should eq "public/system/chapters/#{chap.name}/assets/paragraph.jpg"
        end
        it "should interpolate the correct path for a subclass instance" do
          chapter = Chapters::Assets::Paragraph.create!(:chapter => chap, :asset => uploaded_test_asset)
          chapter.asset.path.should eq "public/system/chapters/#{chap.name}/assets/paragraph_2.jpg"
        end
      end
    end
  end

  context "using paperclip styles" do

    context "given a class of type Books::Assets::TestImage that add :thumb and :medium style" do
      subject { Books::Assets::TestImage.new }

      it "should add styles to attachment definitions" do
        definitions = subject.class.attachment_definitions[:asset][:styles]
        definitions.should include(:thumb)
        definitions.should include(:medium)
      end
      it "should include :style interpolation in the path definition" do
        subject.class.attachment_definitions[:asset][:path].should == ":acts_as_assets_file_path/:style/:acts_as_assets_file_name.:extension"
      end
      it "should create the thumb/medium and original image in the correct path" do
        doc = Books::Assets::TestImage.create! :asset => uploaded_test_asset, :book => book
        doc.asset.path(:thumb).should eq "public/system/books/#{book.id}/assets/thumb/test_image.jpg"
        doc.asset.path(:original).should eq "public/system/books/#{book.id}/assets/original/test_image.jpg"
        doc.asset.path(:medium).should eq "public/system/books/#{book.id}/assets/medium/test_image.jpg"
      end
      it "should have style param in the url" do
        doc = Books::Assets::TestImage.create! :asset => uploaded_test_asset, :book => book
        doc.asset.url(:thumb).should match  /\/books\/#{book.id}\/assets\/get\/#{doc.id}\/thumb\/#{doc.asset.to_file.original_filename}/
        doc.asset.url(:medium).should match  /\/books\/#{book.id}\/assets\/get\/#{doc.id}\/medium\/#{doc.asset.to_file.original_filename}/
        doc.asset.url(:original).should match  /\/books\/#{book.id}\/assets\/get\/#{doc.id}\/original\/#{doc.asset.to_file.original_filename}/
      end

    end

    context "foreign_key" do
      it "should have a method to hold the foreign key if specified" do
        Chapters::Asset.should respond_to :foreign_key_name
      end

      it "should return the :foreign_key option when specified" do
        Chapters::Asset.foreign_key_name.should eq :chapter_name
      end

      it "should return the :foreign_key option when specified even for the child classes" do
        Chapters::Assets::Paragraph.foreign_key_name.should eq :chapter_name
      end

      it "should fallback on asset_id if foreign key not specified" do
        Books::Asset.foreign_key_name.should eq :book_id
      end
    end

  end

end
