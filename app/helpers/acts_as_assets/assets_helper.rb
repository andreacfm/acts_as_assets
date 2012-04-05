module ActsAsAssets::AssetsHelper
  def destroy_path asset, target
    send(destroy_method_for(asset), instance_variable_get("@#{name_from(asset)}"), :asset_id => asset.id, :target => target)
  end

  def destroy_method_for(asset)
    "#{name_from(asset)}_destroy_asset_path".to_sym
  end

  def name_from(asset)
    asset.class.root_model_name
  end

end