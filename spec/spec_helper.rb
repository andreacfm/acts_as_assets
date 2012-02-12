# encoding: utf-8
require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'

require 'rails/all'
require 'acts_as_assets'
require 'rack/test/uploaded_file'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

require 'rspec/rails'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :suite do
    ActiveRecord::Base.connection.create_table(:documents,:force => true) do |t|
      t.boolean :ok
      t.datetime :date_ok
      t.boolean :another_ok
      t.datetime :custom_date
    end
  end

  config.before(:each) do
    Document.delete_all
  end

  config.after(:suite) do
    ActiveRecord::Base.connection.drop_table(:documents)
  end
end
