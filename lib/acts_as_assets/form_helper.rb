module ActionView
  module Helpers
    class FormBuilder
      def asset_upload(method, type, *args)
        @template.asset_upload_tag(@object, method, type, *args)
      end

      def asset_multiple_upload(method, type, *args)
        @template.asset_multiple_upload_tag(@object, method, type, *args)
      end

      def asset_label(method, type)
        @template.asset_label_tag(@object, method, type)
      end
    end

    module FormTagHelper
      def asset_multiple_upload_tag(model, methods, type, *args)
        options = args.extract_options!
        asset_upload_helper(model, methods, type, "acts_as_assets/assets/asset_multiple_upload", options)
      end

      def asset_upload_tag(model, methods, type, *args)
        options = args.extract_options!
        asset_upload_helper(model, methods, type, "acts_as_assets/assets/asset_upload", options)
      end

      private

      # +methods+ can be a sym that will be the method name and it will be called
      # against the model passed or can an array of symbols and will be chained in a method call
      # for instance
      # asset_upload_tag(@pratica, [:back_office, :allegati], ...)
      # will call @pratica.back_office.allegati
      def asset_upload_helper(model, methods, type, partial, options)
        render partial: partial,
               locals: {:@type => type, model: model, assets: model_assets(methods, model),
                        association: Array(methods).last,
                        read_only: options[:read_only]}
      end

      def model_assets(methods, model)
        Array(methods).inject(model) { |object, method| object.send(method) }
      end

    end
  end
end
