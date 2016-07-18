class YoutubeUploadAdminController < ApplicationController
  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0
    @videos = YoutubeUpload.order(published_at: :desc).limit(limit)
  end

  def new
    @video, @url = YoutubeUpload.new, url_for(action: 'create')
  end

  def show
    @video, msg, code = YoutubeUpload._find(params[:id])
    flash[:notice] = msg
  end

  def edit
    @url = url_for(action: 'update', id: params[:id])
    @video, msg, code = YoutubeUpload._find(params[:id])
    flash[:notice] = msg
  end

  def update
    @video, msg, code = YoutubeUpload._update(params[:id], youtube_video_params)
    flash[:notice] = msg
    if code == 200
      render 'show'
    else
      @url = url_for(action: 'update', id: params[:id])
      render 'edit'
    end
  end

  def destroy
    video, msg, code = YoutubeUpload._destroy(params[:id])
    flash[:notice] = msg
    redirect_to action: 'index'
  end

  private
    def youtube_video_params
      params.require(:youtube_upload).permit(:uchannel_id, :youtube_id, :duration, :published_at, :title, :description, :thumbnail_small, :thumbnail_medium, :thumbnail_large, :tags, :category_id, :live_broadcast_content, :upload_status, :privacy_status, :embeddable)
    end

end
