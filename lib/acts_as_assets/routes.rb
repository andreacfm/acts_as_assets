module ActionDispatch::Routing
  class Mapper

    def assets_routes_for(resources)
      resources = Array(resources)
      resources.each do |r|
        plural = r.to_s
        singolar = plural.singularize
        scope "#{plural}/:fk_name/assets/" do
          get "get/:asset_id/(:style)/:filename.:extension" => "#{plural}/assets#get", :as => "#{plural}_get_asset"
          get "*type" => "#{plural}/assets#index", :as => "#{singolar}_assets"
          post "*type" => "#{plural}/assets#create", :as => "#{singolar}_create_asset"
          delete ":asset_id" => "#{plural}/assets#destroy", :as => "#{singolar}_destroy_asset"
        end

      end

    end

  end
end