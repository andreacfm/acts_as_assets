class Book < ActiveRecord::Base
  has_many :assets, :class_name => "Books::Asset"
end