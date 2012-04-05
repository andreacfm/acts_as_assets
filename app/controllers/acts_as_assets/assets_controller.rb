class ActsAsAssets::AssetsController < ApplicationController
  include ActsAsAssets::AssetsHelper
  helper_method :destroy_path
  before_filter :assign_root_model
  before_filter :load_model
  before_filter :assign_target, :only => [:index, :destroy]
  before_filter :load_assets, :only => [:index]

  def index
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render :json => @assets }
    end
  end


  def create
    puts "----------------->>>>>>>>>>>>>> #{klazz.model_sym}"
    puts "----------------->>>>>>>>>>>>>> #{@model}"

    @asset = klazz.create(:asset => params[:file], :asset_content_type => mime_type(params[:file]), klazz.model_sym => @model)

    respond_to do |format|
      if @asset.valid?
        format.js
      else
        format.js { render :json => {:success => false, :errors => @asset.errors} }
      end
    end
  end

  def destroy
    begin
      @asset = @model.send(:assets).find_by_id(params[:asset_id])
      @asset.destroy
    rescue Exception => e
      error = e.message
    end

    respond_to do |format|
      if error.nil?
        format.js
      else
        format.js { render :json => {:success => false, :errors => error} }
      end
    end

  end

  def get
    begin
      @asset = @model.send(:assets).find(params[:asset_id])

      send_file(actual_file_path, {:filename => @asset.asset.to_file.original_filename, :content_type => @asset.asset_content_type, :disposition => 'inline'})

    rescue ActiveRecord::RecordNotFound
      respond_with_404
    end
  end

  def actual_file_path
    @path = params[:style].nil? ? @asset.asset.path : @asset.asset.path(params[:style])
  end

  def load_assets
    @assets = klazz.send(:where, klazz.foreign_key_name => params[klazz.foreign_key_name])
  end

  def load_model
    @model ||= instance_variable_get("@#{klazz.model_sym}")
  end

  def klazz
    ([self.class.to_s.split('::').first] << camelize_type).join('::').constantize
  end

  def assign_root_model
    puts "-------------->>>>>>>>>>>>>>> klazz.foreign_key_name: #{klazz.foreign_key_name}"
    puts "-------------->>>>>>>>>>>>>>> #{klazz.model_name.camelize}.find('#{params[klazz.foreign_key_name]}')"
    instance_variable_set "@#{klazz.model_name}",
                          klazz.model_name.camelize.constantize.send(:find, params[klazz.foreign_key_name])
  end

  def assign_target
    @target = params[:target]
  end

  ## takes a type params string like "my/asset/type_of_documento" and convert into [My,Asset,TypeOfDocument]
  def camelize_type
    params[:type].split('/').map { |i| i.camelize }.flatten if params[:type]
  end

  private

  def respond_with_404
    render :file => "#{Rails.root}/public/404.html", :status => :not_found
  end

  def mime_type(file)
    MIME::Types.type_for(file.original_filename)[0].to_s
  end

end