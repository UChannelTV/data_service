class VideoUploadsController < ApiController
  def initialize
    super(VideoUpload)
  end

  def index
    render json: VideoUpload._find(params["video_id"], params[:host], params[:host_id])
  end

  def video
    msg, code = VideoUpload._setVideoID(params[:video_id], params[:host], params[:host_id])
    render json: {"msg" => msg}, status: code
  end

  def enable
    msg, code = VideoUpload.enable(params[:host], params[:host_id])
    render json: {"msg" => msg}, status: code
  end

  def disable
    msg, code = VideoUpload.disable(params[:host], params[:host_id])
    render json: {"msg" => msg}, status: code
  end

  def destroy
    msg, code = VideoUpload._destroy(params[:host], params[:host_id])
    render json: {"msg" => msg}, status: code
  end
    
end
