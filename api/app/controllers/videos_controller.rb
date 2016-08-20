class VideosController < ApiController
  skip_before_filter :authenticate, :only => [:formatted, :category]
  @@query = "left join video_uploads on videos.id = video_id and host = 'youtube' and enabled = 1"

  def initialize
    super(Video)
  end

  def list_status
    render json: VideoStatus.all
  end

  def formatted 
    video = Video.joins(:category).joins(@@query).
        select("videos.title, videos.description, video_categories.qr_code, video_uploads.host_id").
        where(id: params[:id]).first
    if video.nil?
      video = {}
    else
      video = {"title" => video.title, "description" => video.description, "qr_code" => video.qr_code, "youtube_id" => video.host_id}
    end
    render json: video
  end

  def category
    limit, first_id, cid = params[:limit].to_i, params[:start_video].to_i, params[:id].to_i
    
    if cid == 0 || limit == 0
      render json: {"videos":[]}
    else
      videos = getVideos(cid, first_id, limit).collect{|x| x.as_json}
      
      if videos.size > limit
        render json: {"videos" => videos[0, limit], "next" => videos[limit]["id"]}
      else
        render json: {"videos" => videos}
      end
    end
  end

  private
  def getVideos(cid, first_id, limit)
    if first_id == 0
      return Video.where(category_id: cid).where(status_id: 2).where(parent_video: nil).
        select("id, title, thumbnail, duration").order(created_at: :desc, id: :desc).
        limit(limit+1)
    end

    video = Video.find_by(id: first_id)
    return [] if video.nil?
    return Video.where(category_id: cid).where(status_id: 2).where(parent_video: nil).
        where("(created_at = '#{video.created_at}' and id <= #{first_id}) || created_at < '#{video.created_at}'").
        select("id, title, thumbnail, duration").order(created_at: :desc, id: :desc).
        limit(limit+1)
  end
end
