module ActionView
  module Helpers
    class FormBuilder
      def asset_upload(method, type)
        @template.asset_upload_tag(@object, method, type)
      end
      def asset_multiple_upload(method, type)
        @template.asset_multiple_upload_tag(@object, method, type)
      end
    end

    module FormTagHelper
      def asset_multiple_upload_tag(model, method, type)
        asset_upload_tag(model, method, type, true)
      end

      # +methods+ can be a sym that will be the method name and it will be called
      # against the model passed or can an array of symbols and will be chained in a method call
      # for instance
      # asset_upload_tag(@pratica, [:back_office, :allegati], ...)
      # will call @pratica.back_office.allegati
      def asset_upload_tag(model, methods, type, multiple=false)
        render :partial => "acts_as_assets/assets/file_upload",
               :locals => {:@type => type, :multiple => multiple, :model => model, :assets => model_assets(methods, model)}
      end

      def call

      end

      def model_assets(methods, model)
        Array(methods).inject(model) {|object, method| object.send(method) }
      end
    end
  end
end
