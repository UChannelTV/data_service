class YoutubeUploadsController < ApplicationController
  # GET /youtube_videos
  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0
    render :json => YoutubeUpload.order(published_at: :desc).limit(limit)
  end

  # GET /youtube_videos/:id
  def show
    data, msg, code = YoutubeUpload._find(params[:id])
    rsp(data, msg, code, 200)
  end

  # POST /youtube_videos
  def create
    data, msg, code = YoutubeUpload._create(youtube_video_params)
    rsp(data, msg, code, 201)
  end

  # PUT /youtube_videos/:id
  def update
    data, msg, code = YoubuteUpload._update(params[:id], youtube_video_params)
    rsp(data, msg, code, 200) 
  end

  # DELETE /youtube_videos/:id
  def destroy
    data, msg, code = YoutubeUpload._destroy(params[:id])
    render json: {"msg" => msg}, status: code
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def youtube_video_params
      params.require(:youtube_upload).permit(:uchannel_id, :youtube_id, :duration, :published_at, :title, :description, :thumbnail_small, :thumbnail_medium, :thumbnail_large, :tags, :category_id, :live_broadcast_content, :upload_status, :privacy_status, :embeddable)
    end

    def rsp(data, msg, code, match)
      if code == match
        render json: data, status: code
      else
        render json: {"error" => msg}, status: code
      end
    end
end
