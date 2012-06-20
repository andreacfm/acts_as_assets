module ActionView
  module Helpers
    class FormBuilder
      def asset_upload(methods, *args)
        @template.asset_upload_tag(@object, methods, *args)
      end

      def asset_multiple_upload(methods, *args)
        @template.asset_multiple_upload_tag(@object, methods, *args)
      end

      def asset_label(methods, type)
        @template.asset_label_tag(@object, methods, type)
      end
    end

    module FormTagHelper
      def asset_multiple_upload_tag(model, methods, *args)
        options = args.extract_options!
        type = nil
        type = args.first if args.size == 2
        asset_upload_helper(model, methods, type, "acts_as_assets/assets/asset_multiple_upload", options)
      end

      def asset_upload_tag(model, methods, *args)
        options = args.extract_options!
        type = nil
        type = args.first if args.size == 2
        asset_upload_helper(model, methods, type, "acts_as_assets/assets/asset_upload", options)
      end

      # +methods+ can be a sym that will be the method name and it will be called
      # against the model passed or can an array of symbols and will be chained in a method call
      # for instance
      # asset_upload_tag(@pratica, [:back_office, :allegati], ...)
      # will call @pratica.back_office.allegati
      def asset_upload_helper(model, methods, type, partial, options)
        type ||= get_type_from_association(model, methods)
        render partial: partial,
               locals: {:@type => type, model: model, assets: asset_instances(model, methods), read_only: options[:read_only]}
      end

      def asset_instances(model, methods)
        Array(methods).inject(model) { |object, method| object.send(method) }
      end

      def get_type_from_association(model, methods)
        meths = Array(methods).dup

        association_name = meths.pop

        unless meths.empty?
          model = asset_instances(model, meths)
        end

        model.association(association_name).klass.to_s.underscore
      end
    end
  end
end
