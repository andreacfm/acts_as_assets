module ActionView
  module Helpers
    class FormBuilder
      def asset_upload(method, type)
        @template.asset_upload_tag(@object, method, type)
      end
    end

    module FormTagHelper
      def asset_multiple_upload_tag(model, method, type)
        asset_upload_helper_tag(model, method, type, true)
      end

      def asset_upload_tag(model, method, type, multiple=false)
        render :partial => "acts_as_assets/assets/file_upload",
               :locals => {:@type => type,:multiple => multiple,:model => model,:assets => model.send(method)}
      end
    end
  end
end
