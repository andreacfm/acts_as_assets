module ActsAsAssets::AssetsHelper
  def destroy_path(asset, model, target, type)
    send(destroy_method_for(asset), model, {:asset_id => asset.id, :target => target, :type => type})
  end

  def destroy_method_for(asset)
    "#{name_from(asset)}_destroy_asset_path".to_sym
  end

  def name_from(asset)
    asset.class.base_model_name
  end

  def asset_target
    @type.split('/').join('_')
  end

  def upload_complete_js_function
    "function(id, fileName, responseJSON, qq){K.allegati.onComplete(id, fileName, responseJSON, qq,'#{asset_target}');}"
  end
  def asset_action(model)
    method_name = "#{model.class.model_name.split('::').first.underscore.singularize}_create_asset_path".to_sym
    self.send(method_name, model, :type => @type, :format => :js)
  end

  def destroy_file_path(asset, model)
    destroy_path(asset, model, asset_target, @type)
  end

  def destroy_link(asset, model)
    link_to(I18n.translate('destroy'), destroy_file_path(asset, model), {:method => :delete, :confirm => 'Sei Sicuro?', :remote => true})
  end

  def asset_label
    defined?(type_label).nil? ? @type.split('/').last.to_s.humanize : type_label
  end

  def asset_id
    asset_target
  end

  def asset_file_name(asset)
    File.basename(asset.asset.path)
  end
  def asset_file_path(asset)
    asset.asset.url
  end

  def assets_body
    j render(:partial => @asset_partial, :locals => {:assets => Array(@assets), :model => @model})
  end
end