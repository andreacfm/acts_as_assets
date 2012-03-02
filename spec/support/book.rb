class Book < ActiveRecord::Base
  has_many :assets, :class_name => "Books::Asset"
end

module Books
  class Asset < ActiveRecord::Base
    self.table_name = "books_assets"
    acts_as_assets
  end
end

module Books
  module Assets
    class TestDoc < Books::Asset
    end
  end
end

module Books
  module Assets
    class UniqueTestDoc < Books::Asset
      include ActsAsAssets::UniqueAsset
    end
  end
end

module Books
  class Image < Books::Asset
  end
end

module Books
  module Assets
    class TestImage < Books::Image
      acts_as_assets :styles => {:thumb => "64x64", :medium => "128x128"}
    end
  end
end

