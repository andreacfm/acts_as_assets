module ActsAsAssets::AssetsHelper
  def destroy_link(asset, model)
      link_to(I18n.translate('destroy'), destroy_file_path(asset, model), {method: :delete, data: {:confirm => 'Sei Sicuro?'}, :remote => true})
    end

  def destroy_file_path(asset, model)
    destroy_path(asset, model, asset_target(model), @type)
  end

  def asset_target model
    @type.gsub(/\//, '_') + "_#{model.id}"
  end

  def destroy_path(asset, model, target, type)
    send(destroy_method_for(asset), model, {:asset_id => asset.id, :target => target, :type => type})
  end

  def destroy_method_for(asset)
    "#{name_from(asset)}_destroy_asset_path".to_sym
  end

  def get_file_path(asset, model)
    get_path(asset, model, @type)
  end

  def get_path(asset, model, type)
    send(get_method_for(asset), model.to_model, asset, {:asset_id => asset.id, :type => type})
  end

  def get_method_for(asset)
    "#{name_from(asset)}_get_asset_path".to_sym
  end

  def name_from(asset)
    asset.class.base_model_sym
  end

  def asset_label
    defined?(type_label).nil? ? @type.split('/').last.to_s.humanize : type_label
  end

  def upload_complete_js_function model
    "function(id, fileName, responseJSON, qq){K.allegati.onComplete(id, fileName, responseJSON, qq,'#{asset_target(model)}');}"
  end
  def asset_action(model)
    prefix = model.to_model.class.to_s.underscore.gsub(/\//, '_')
    method_name = "#{prefix}_create_asset_path".to_sym
    self.send(method_name, model, :type => @type, :format => :js)
  end

  def asset_id model
    asset_target model
  end

  def asset_file_name(asset)
    File.basename(asset.asset.path)
  end
  def asset_file_path(asset)
    asset.asset.url
  end

  def assets_body
    j render(:partial => @asset_partial, :locals => {:assets => Array(@assets), :model => @model, read_only: false})
  end
end