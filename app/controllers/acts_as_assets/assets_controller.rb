class ActsAsAssets::AssetsController < ApplicationController
  include ActsAsAssets::AssetsHelper
  helper_method :destroy_path

  before_filter :load_type
  before_filter :assign_target, :only => [:index, :destroy]
  before_filter :load_assets, :only => [:index, :destroy]

  def index
    @model = klazz.base_model.find(CGI.unescape(params[klazz.foreign_key_name]))
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render :json => @assets }
    end
  end

  def create
    @model = klazz.base_model.find(CGI.unescape(params[klazz.foreign_key_name]))
    @asset = klazz.create(
            :asset => params[:file],
            :asset_content_type => mime_type(params[:file]),
            klazz.base_model_sym => @model)

    @asset_partial = partial_to_use(@asset)
    respond_to do |format|
      if @asset.valid?
        load_assets
        format.js
      else
        format.js { render :json => {:success => false, :errors => @asset.errors} }
      end
    end
  end

  def destroy
    begin
      @model = klazz.base_model.find(CGI.unescape(params[klazz.foreign_key_name]))
      @asset = klazz.find_by_id(params[:asset_id])
      @asset_partial = partial_to_use(@asset)
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
      @asset = klazz.find(params[:asset_id])

      send_file(file_to_download_path, {:filename => @asset.asset.to_file.original_filename, :content_type => @asset.asset_content_type, :disposition => 'inline'})

    rescue ActiveRecord::RecordNotFound
      respond_with_404
    end
  end

  private
  def file_to_download_path
    @path = params[:style].nil? ? @asset.asset.path : @asset.asset.path(params[:style])
  end

  def partial_to_use(asset)
    asset.multiple? ? "acts_as_assets/assets/asset_multiple_upload" : "acts_as_assets/assets/asset_upload"
  end

  def load_assets
    @assets = klazz.where(klazz.foreign_key_name => CGI.unescape(params[klazz.foreign_key_name]))
  end

  def klazz
    ([self.class.to_s.split('::').first] << camelize_type).join('::').constantize
  end

  ## takes a type params string like "my/asset/type_of_documento" and convert into [My,Asset,TypeOfDocument]
  def camelize_type
    params[:type].split('/').map { |i| i.camelize }.flatten
  end

  def assign_target
    @target = params[:target]
  end

  def mime_type(file)
    MIME::Types.type_for(file.original_filename)[0].to_s
  end

  def load_type
    raise ":type of asset is mandatory and not specified" unless params[:type]
    @type = params[:type]
  end


  def respond_with_404
    render :file => "#{Rails.root}/public/404.html", :status => :not_found
  end

end