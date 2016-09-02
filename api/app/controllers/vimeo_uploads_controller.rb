class VimeoUploadsController < ApiController
  def initialize
    super(VimeoUpload)
  end

  # GET /vimeo_videos
  def index
    limit = params[:limit].to_i
    limit = 100 if limit == 0

    render json: VimeoUpload.order(published_at: :desc).limit(limit)
  end
end
