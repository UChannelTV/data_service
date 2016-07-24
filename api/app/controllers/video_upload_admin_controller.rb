class VideoUploadAdminController < AdminController
  def initialize
    super(VideoUpload)
  end

  def index
    @video_id, @host, @host_id = params[:video_id], params[:host], params[:host_id]
    @records = VideoUpload._find(@video_id, @host, @host_id).collect{|x| x.as_json}
  end
end
