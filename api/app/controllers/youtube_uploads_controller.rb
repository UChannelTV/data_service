class YoutubeUploadsController < ApiController
  def initialize
    super(YoutubeUpload)
  end

  # GET /youtube_videos
  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0

    render json: YoutubeUpload.order(published_at: :desc).limit(limit)
  end
end
