require "acts_as_assets/paperclip/interpolations"
require "acts_as_assets/unique_asset"

module ActsAsAssets

  module Base
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end
  end

  module ClassMethods
    def acts_as_assets *args
      cattr_accessor :foreign_key_name

      include InstanceMethods
      belongs_to model_sym

      options = args.extract_options!

      paperclip_config = {
          :url => options.include?(:styles) ?
              "/#{model_sym.to_s.pluralize}/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:style/:acts_as_assets_file_name.:extension" :
              "/#{model_sym.to_s.pluralize}/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:acts_as_assets_file_name.:extension",
          :path => options.include?(:styles) ? ":acts_as_assets_file_path/:style/:acts_as_assets_file_name.:extension" : ":acts_as_assets_file_path/:acts_as_assets_file_name.:extension"
      }


      self.foreign_key_name = (options[:foreign_key] || "#{root_model_name}_id").to_sym

      has_attached_file :asset, paperclip_config.merge(options)

      before_create :touch_counter
    end

    def root_model_name
      self.to_s.split('::').first.underscore.singularize
    end

    def model_sym
      root_model_name.to_sym
    end

  end

  module InstanceMethods
    def acting_as_assets?
      true
    end

    private

    def touch_counter
      max = self.class.maximum(:counter, :conditions => {self.class.foreign_key_name => self.send(self.class.foreign_key_name)})
      self.counter = max.to_i + 1
    end

    def root_id
      send(self.class.foreign_key_name)
    end

    def acts_as_assets_file_path
      a = ActiveSupport::Inflector.underscore(self.type).split('/').prepend "public", "system"
      a.pop
      root_model_index = a.index(self.class.model_sym.to_s.pluralize)
      a.insert root_model_index + 1, root_id
      a.join '/'
    end

    def acts_as_assets_file_name
      a = ActiveSupport::Inflector.underscore(self.type).split('/')
      self.counter > 1 ? "#{a.last}_#{counter}" : a.last
    end

  end

end

ActiveRecord::Base.send :include, ActsAsAssets::Base
