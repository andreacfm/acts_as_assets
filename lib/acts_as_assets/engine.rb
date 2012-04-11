module ActsAsAssets
  class Engine < ::Rails::Engine
    initializer "acts_as_assets.add_form_builder_extensions", :after=>"bootstrap_hook" do |app|
      require "acts_as_assets/form_helper"
    end
  end
end
