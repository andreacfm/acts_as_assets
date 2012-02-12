module Books
  class Asset < ActiveRecord::Base
    self.table_name = "books_assets"
    acts_as_assets
  end
end