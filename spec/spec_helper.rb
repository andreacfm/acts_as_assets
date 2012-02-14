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
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

require 'rspec/rails'

RSpec.configure do |config|
  include Shoulda::Matchers::ActionController
  include Paperclip::Shoulda::Matchers

  config.mock_with :rspec

  config.before :suite do
    ActiveRecord::Base.connection.create_table(:books,:force => true) do |t|
      t.string :title
    end
    ActiveRecord::Base.connection.create_table(:books_assets,:force => true) do |t|
      t.has_attached_file :asset
      t.string :type
      t.integer :counter, :default => 0, :null => false
      t.integer :book_id
    end
    Rails.application.routes.draw do
      namespace :books do
        scope ":book_id/assets" do
          get '*type' => 'assets#index', :as => 'assets'
          post ':type' => 'assets#create', :as => 'assets_create'
          delete ':asset_id' => 'assets#destroy', :as => 'assets_destroy'
        end
      end
    end

  end

  #destroy created assets
  config.before :all do
    @dtbd = []
  end
  config.after :all do
    @dtbd.each {|d| d.destroy unless d.nil? }
  end

  config.before(:each) do
    Books::Asset.delete_all
    Book.delete_all
  end

  config.after(:suite) do
  end

  def jpg_test
    Rack::Test::UploadedFile.new(File.expand_path('../resources/jpg_test.jpg',__FILE__), "image/jpeg")
  end

end