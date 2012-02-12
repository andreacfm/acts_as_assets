module ActsAsAssets

  module Base

    def self.included base
      base.class_eval do
        extend ClassMethods
      end
    end

  end

  module ClassMethods

    def acts_as_assets
      include InstanceMethods

      belongs_to root_model
      has_attached_file :asset,
                        :url => "/documents/#{root_model.to_s}/:acts_as_assets_root_id/:acts_as_assets_asset_id",
                        :path => "public/system/#{root_model.to_s}/:acts_as_assets_root_id/:acts_as_assets_file_name.:extension"
      before_create :touch_counter

      Paperclip.interpolates :acts_as_assets_root_id do |doc, style|
        doc.instance.send(:root_id)
      end

      Paperclip.interpolates :acts_as_assets_file_name do |doc, style|
        doc.instance.send(:create_file_name)
      end

      Paperclip.interpolates :acts_as_assets_asset_id do |doc, style|
        doc.instance.id
      end

      private
      define_method(:touch_counter) do
        max = self.class.maximum(:counter, :conditions => {"#{self.class.root_model}_id".to_sym => self.send("#{self.class.root_model}_id".to_sym)})
        self.counter = max.nil? ? 1 : max+1
      end

      define_method(:root_id) do
        send(self.class.root_model).id
      end

    end

    def root_model
      ActiveSupport::Inflector.underscore(self.to_s.split('::').first.singularize).to_sym
    end

  end

  module InstanceMethods

    private
    def create_file_name
      a = ActiveSupport::Inflector.underscore(self.type).split('/')
      file_name = "fv_#{root_id}_#{a.last}"
      a.pop
      a.shift if a.first == "pratiche"
      a << file_name
      a.join '/'
    end

  end

end

ActiveRecord::Base.send :include, ActsAsAssets::Base