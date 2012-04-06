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


      options = args.extract_options!

      paperclip_config = {
          :url => options.include?(:styles) ?
              "/#{model_sym.to_s.pluralize}/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:style/:acts_as_assets_file_name.:extension" :
              "/#{model_sym.to_s.pluralize}/:acts_as_assets_root_id/assets/get/:acts_as_assets_asset_id/:acts_as_assets_file_name.:extension",
          :path => options.include?(:styles) ? ":acts_as_assets_file_path/:style/:acts_as_assets_file_name.:extension" : ":acts_as_assets_file_path/:acts_as_assets_file_name.:extension"
      }

      self.foreign_key_name = (options[:foreign_key] || "#{asset_model_name}_id").to_sym

      belongs_to model_sym, :foreign_key => self.foreign_key_name

      has_attached_file :asset, paperclip_config.merge(options)

      before_create :increment_counter
    end

    def asset_model_name
      self.to_s.split('::').first.underscore.singularize
    end

    def model_sym
      asset_model_name.to_sym
    end

  end

  module InstanceMethods
    def acting_as_assets?
      true
    end

    private
    def increment_counter
      self.counter = number_of_file_for_type + 1
    end

    def number_of_file_for_type
      self.class.maximum(:counter, :conditions => {self.class.foreign_key_name => self.send(self.class.foreign_key_name)}).to_i
    end

    def model_fk
      send(self.class.foreign_key_name)
    end

    def acts_as_assets_file_path
      a = absolute_directory_for_asset_as_array
      root_model_index = a.index(self.class.asset_model_name.pluralize)
      a.insert(root_model_index + 1, model_fk)
      a.join('/')
    end

    def acts_as_assets_file_name
      self.counter > 1 ? "#{_file_name}_#{counter}" : _file_name
    end

    def _file_name
      relative_directory_for_asset_as_array.last
    end

    def relative_directory_for_asset_as_array
      self.type.underscore.split('/')
    end

    def absolute_directory_for_asset_as_array
      relative_directory_for_asset_as_array.unshift("public", "system").instance_eval { pop; self }
    end
  end

end

ActiveRecord::Base.send :include, ActsAsAssets::Base
