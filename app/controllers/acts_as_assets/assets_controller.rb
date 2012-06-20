class ActsAsAssets::AssetsController < ApplicationController
  include ActsAsAssets::AssetsHelper
  helper_method :destroy_path

  before_filter :load_type
  before_filter :assign_target, :only => [:index, :destroy]
  before_filter :load_assets, :only => [:index, :destroy]

  def index
    @model = assets_base_model
    respond_to do |format|
      format.html { render :layout => false }
      format.json { render :json => @assets }
    end
  end

  def create
    @model = assets_base_model
    @asset = klazz.create(:asset => params[:file],
                          :asset_content_type => mime_type(params[:file]),
                          klazz.base_model_sym => @model)
    @download_prefix = klazz.download_prefix
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
      @model = assets_base_model
      @download_prefix = klazz.download_prefix
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
      send_file(file_to_download_path, {:filename => File.basename(@asset.asset.path), :content_type => @asset.asset_content_type, :disposition => 'inline'})
    rescue ActiveRecord::RecordNotFound
      respond_with_404
    end
  end

  protected
  def assets_base_model
    klazz.base_model.find(CGI.unescape(params[:fk_name]))
  end
  private
  def file_to_download_path
    @path = params[:style].nil? ? @asset.asset.path : @asset.asset.path(params[:style])
  end

  def partial_to_use(asset)
    asset.multiple? ? "acts_as_assets/assets/asset_multiple_upload" : "acts_as_assets/assets/asset_upload"
  end

  def load_assets
    raise "A param :fk_name with the value of the base_model id must be provided. Check the routes.\n#{params}" if params[:fk_name].nil?
    @assets = klazz.where(klazz.foreign_key_name => CGI.unescape(params[:fk_name]))
  end

  # takes a type params string like "my/asset/type_of_documento"
  # and convert into My::Asset::TypeOfDocument constant
  def klazz
    params[:type].camelize.constantize
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
    render :file => "#{Rails.root}/public/404", :status => :not_found, format: :html
  end

end