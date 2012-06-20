class Chapter < ActiveRecord::Base
  self.primary_key = :name
  attr_accessible :id, :name
  has_one :assets, :class_name => "Chapters::Asset", :foreign_key => "chapter_name"
end
module Chapters
  class Asset < ActiveRecord::Base
    self.table_name = "chapters_assets"
    acts_as_assets base_model: :chapter, :foreign_key => :chapter_name
  end
end
module Chapters
  module Assets
    class Paragraph < Chapters::Asset
    end
  end
end
