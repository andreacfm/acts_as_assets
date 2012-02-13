class ActsAsAssets::AssetsController < ApplicationController
  include ActsAsAssets::AssetsHelper
  helper_method :destroy_path
  before_filter "assign_root_model"
  before_filter "assign_target", :only => [:index,:destroy]

  def index
    load_assets
    render 'acts_as_assets/assets/index', :layout => false
  end

  def create
    name = root_model_name
    klazz = ([name.pluralize.camelize] << camelize_type.flatten).join('::')
    @asset = klazz.constantize.create!(:asset => params[:file],
                              "#{name}".to_sym => instance_variable_get("@#{name}".to_sym))

    respond_to do |format|
      if @asset.valid?
        format.js { render :json => {:success => true} }
      else
        format.js { render :json =>{:success => false, :errors => @asset.errors} }
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
        format.js { render 'acts_as_assets/assets/destroy'}
      else
        format.js { render :json => {:success => false, :errors => error} }
      end
    end

  end


  private

  def load_assets
    name = root_model_name
    klazz = ([name.pluralize.camelize] << camelize_type.flatten).join('::')
    @assets = klazz.constantize.send(:where,"#{name}_id".to_sym => params["#{name}_id".to_sym])
  end

  def assign_root_model
    name = root_model_name
    instance_variable_set "@#{name}", name.camelize.constantize.send(:find, params["#{name}_id".to_sym])
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

end