class ActsAsAssets::AssetsController < ApplicationController
  include ActsAsAssets::AssetsHelper
  helper_method :destroy_path
  before_filter "assign_root_model"
  before_filter "assign_target", :only => [:index,:destroy]

  def index
    load_assets
    respond_to do |format|
      format.html{render :layout => false}
      format.json{render :json => @assets}
    end
  end


  def create
    @asset = klazz.create(:asset => params[:file],
                                      :asset_content_type => MIME::Types.type_for(params[:file].original_filename)[0].to_s,
                                      "#{root_model_name}".to_sym => instance_variable_get("@#{root_model_name}".to_sym))
    respond_to do |format|
      if @asset.valid?
        format.js
      else
        format.js { render :json =>{:success => false, :errors => @asset.errors}}
      end
    end
  end

  def destroy

    begin
      @asset = instance_variable_get("@#{root_model_name}").send(:assets).find_by_id(params[:asset_id])
      @asset.destroy
    rescue Exception => e
      error = e.message
    end

    respond_to do |format|
      if error.nil?
        format.js
      else
        format.js { render :json => {:success => false, :errors => error}}
      end
    end

  end

  def get
    begin
      @asset = instance_variable_get("@#{root_model_name}").send(:assets).find(params[:asset_id])
    rescue ActiveRecord::RecordNotFound
      respond_with_404  and return
    end
    @path = params[:style].nil? ? @asset.asset.path : @asset.asset.path(params[:style])
    send_file(@path, {:filename => @asset.asset.to_file.original_filename, :content_type => @asset.asset_content_type, :disposition => 'inline'})
  end

  private

  def load_assets
    @assets = klazz.send(:where,"#{root_model_name}_id".to_sym => params["#{root_model_name}_id".to_sym])
  end

  def klazz
    ([root_model_name.pluralize.camelize] << camelize_type.flatten).join('::').constantize
  end

  def assign_root_model
    instance_variable_set "@#{root_model_name}", root_model_name.camelize.constantize.send(:find, params["#{root_model_name}_id".to_sym])
  end

  def root_model_name
    ActiveSupport::Inflector.underscore(self.class.to_s.split('::').first.singularize)
  end

  def assign_target
    @target = params[:target]
  end

  # takes a type params string like "my/asset/type_of_documento" and convert into [My,Asset,TypeOfDocument]
  def camelize_type
    params[:type].split('/').collect{|i|i.camelize}
  end

  private

  def respond_with_404
    render :file => "#{Rails.root}/public/404.html", :status => :not_found
  end

end