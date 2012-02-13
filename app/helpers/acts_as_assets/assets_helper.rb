module ActsAsAssets::AssetsHelper

  def destroy_path doc
    name = ActiveSupport::Inflector.underscore(self.class.to_s.split('::').first.singularize)
    method = "#{name.pluralize}_assets_destroy_path"
    send(method.to_sym, instance_variable_get("@#{name}"), :asset_id => doc.id, :target => @target)
  end

end