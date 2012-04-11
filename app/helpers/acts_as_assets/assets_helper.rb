module ActsAsAssets::AssetsHelper
  def destroy_path(asset, target, type)
    send(destroy_method_for(asset), instance_variable_get("@#{name_from(asset)}"), {:asset_id => asset.id, :target => target, :type => type})
  end

  def destroy_method_for(asset)
    "#{name_from(asset)}_destroy_asset_path".to_sym
  end

  def name_from(asset)
    asset.class.asset_model_name
  end

  def asset_target
    @type.split('/').join('_')
  end

  def upload_complete_js_function
    "function(id, fileName, responseJSON, qq){K.allegati.onComplete(id, fileName, responseJSON, qq,'#{asset_target}');}"
  end
  def asset_action(model)
    method_name = "#{model.class.model_name.underscore}_create_asset_path".to_sym
    self.send(method_name, model, :type => @type, :format => :js)
  end

  def url(model, type)
    method_name = "#{model.class.model_name.underscore}_assets_path".to_sym
    self.send(method_name, model, :type => @type, :target => asset_target)
  end

  def model_instance(instance)
    instance || @pratica
  end

  def display_document(doc, target, type)
    asset_link = link_to(doc.asset.to_file.original_filename, "#{doc.asset.url}&type=#{type}")

    content_tag(:div, :class => "grid_6 document_link") {asset_link + destroy_link(doc, target, type)} << content_tag(:div, :class => "clear") {}
  end

  def display_image(doc, target, type)
    content_tag :div, :class => "grid_3 document_link image_display" do

      link_to({:url => doc.asset.url(:original)}, :class => "zoom", :rel => "immagine_sito") do
        image_tag(doc.asset.url(:thumb), :alt => 'Apri Immagine')
      end +
      content_tag(:div) { doc.asset.to_file.original_filename } + destroy_link(doc, target, type)
    end
  end

  def destroy_link(doc)
    link_to(I18n.translate('destroy'), destroy_path(doc, @target, @type), {:method => :delete, :confirm => 'Sei Sicuro?', :remote => true})
  end

  def asset_label
    defined?(type_label).nil? ? @type.split('/').last.to_s.humanize : type_label
  end

  def asset_id
    asset_target
  end

  def download_destroy_class
    ""
  end

  def asset_file_name(asset)
    asset.asset.to_file.original_filename
  end
  def asset_file_path(asset)
    asset.asset.url
  end
  def destroy_file_path(asset)
    destroy_path(asset, asset_target, @type)
  end

  def assets_body
    j render(:partial => 'acts_as_assets/assets/asset', :collection => @assets)
  end
end