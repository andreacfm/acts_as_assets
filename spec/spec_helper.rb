# encoding: utf-8
require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'

require 'rails/all'
require 'acts_as_assets'
require 'rack/test/uploaded_file'
require 'paperclip'
require 'shoulda/matchers'
require 'paperclip/matchers'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/*.rb")].each {|f| require f }

require 'rspec/rails'

RSpec.configure do |config|
  include Shoulda::Matchers::ActionController
  include Paperclip::Shoulda::Matchers

  config.mock_with :rspec

  config.before :suite do
    ActiveRecord::Base.connection.create_table(:books, :force => true) do |t|
      t.string :title
    end
    ActiveRecord::Base.connection.create_table(:books_assets, :force => true) do |t|
      t.has_attached_file :asset
      t.string :type
      t.integer :counter, :default => 0, :null => false
      t.integer :book_id
      t.boolean :displayable, :default => false, :null => false
    end
    ActiveRecord::Base.connection.create_table(:chapters, {:id => false, :force => true}) do |t|
      t.string :name, :null => false
    end
    ActiveRecord::Base.connection.create_table(:chapters_assets, :force => true) do |t|
      t.has_attached_file :asset
      t.string :type
      t.integer :counter, :default => 0, :null => false
      t.string :chapter_name
      t.boolean :displayable, :default => false, :null => false
    end
    ActiveRecord::Base.connection.create_table(:rt_tipi_pannello, {:id => false, :force => true}) do |t|
      t.string :name, :null => false
    end
    ActiveRecord::Base.connection.create_table(:rt_tipi_pannello_assets, :force => true) do |t|
      t.has_attached_file :asset
      t.string :type
      t.integer :counter, :default => 0, :null => false
      t.boolean :displayable, :default => false, :null => false
      t.string :tipo_pannello_name
    end
    Rails.application.routes.draw do
      scope "books/:book_id/assets/" do
        get 'get/:asset_id/(:style)/:filename.:extension' => 'books/assets#get', :as => 'book_get_asset'
        get '*type' => 'books/assets#index', :as => 'book_assets'
        post '*type' => 'books/assets#create', :as => 'book_create_asset'
        delete ':asset_id' => 'books/assets#destroy', :as => 'book_destroy_asset'
      end
      scope "chapters/:chapter_name/assets/", :chapter_name => /.*/ do
        get 'get/:asset_id/(:style)/:filename.:extension' => 'chapters/assets#get', :as => 'chapter_get_asset'
        get '*type' => 'chapters/assets#index', :as => 'chapter_assets'
        post '*type' => 'chapters/assets#create', :as => 'chapter_create_asset'
        delete ':asset_id' => 'chapters/assets#destroy', :as => 'chapter_destroy_asset'
      end
      scope "tipi_pannello/:tipo_pannello_name/assets/" do
        get 'get/:asset_id/(:style)/:filename.:extension' => 'tipi_pannello/assets#get', :as => 'tipo_pannello_get_asset'
        get '*type' => 'tipi_pannello/assets#index', :as => 'tipo_pannello_assets'
        post '*type' => 'tipi_pannello/assets#create', :as => 'tipo_pannello_create_asset'
        delete ':asset_id' => 'tipi_pannello/assets#destroy', :as => 'tipo_pannello_destroy_asset'
      end
    end
  end

  config.after :suite do
    require 'fileutils'
    Dir[File.expand_path("../public/*", __FILE__)].each {|file| FileUtils.rm_rf file }
    Dir[File.expand_path("../temp/*", __FILE__)].each {|file| FileUtils.rm_rf file }
    puts "Cleaned up files"
  end

  config.before(:each) do
    Books::Asset.delete_all
    Books::Image.delete_all
    Book.delete_all
  end

  def uploaded_test_asset
    Rack::Test::UploadedFile.new(File.expand_path('../resources/jpg_test.jpg',__FILE__), "image/jpeg")
  end

  #def uploader_field_tag(name, *args); end
end
