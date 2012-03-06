require "acts_as_assets/paperclip/interpolations"
require "acts_as_assets/unique_asset"

module ActsAsAssets

  module Base

    def self.included base
      base.class_eval do
        extend ClassMethods
      end
    end

  end

  module ClassMethods

    def acts_as_assets *args
      include InstanceMethods
      belongs_to root_model

      options = args.extract_options!
      paperclip_config = {
          :url => options.include?(:styles) ?
              "/#{root_model.to_s.pluralize}/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:style/:acts_as_assets_file_name.:extension" :
              "/#{root_model.to_s.pluralize}/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:acts_as_assets_file_name.:extension",
          :path => options.include?(:styles) ? ":acts_as_assets_file_path/:style/:acts_as_assets_file_name.:extension" : ":acts_as_assets_file_path/:acts_as_assets_file_name.:extension"
      }
      has_attached_file :asset, paperclip_config.merge(options)
      before_create :touch_counter
    end

    def root_model
      ActiveSupport::Inflector.underscore(self.to_s.split('::').first.singularize).to_sym
    end

  end

  module InstanceMethods

    def acting_as_assets?
      true
    end

    private

    def touch_counter
      max = self.class.maximum(:counter, :conditions => {"#{self.class.root_model}_id".to_sym => self.send("#{self.class.root_model}_id".to_sym)})
      self.counter = max.nil? ? 1 : max+1
    end

    def root_id
      send(self.class.root_model).id
    end

    def acts_as_assets_file_path
      a = ActiveSupport::Inflector.underscore(self.type).split('/').prepend "public", "system"
      a.pop
      root_model_index = a.index(self.class.root_model.to_s.pluralize)
      a.insert root_model_index + 1,root_id
      a.join '/'
    end

    def acts_as_assets_file_name
      a = ActiveSupport::Inflector.underscore(self.type).split('/')
      self.counter > 1 ? "#{a.last}_#{counter}" : a.last
    end

  end

end

ActiveRecord::Base.send :include, ActsAsAssets::Base