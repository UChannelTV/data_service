class VideosController < ApiController
  skip_before_filter :authenticate, :only => [:formatted, :category, :search, :recent_update]
  @@query = "left join video_uploads on videos.id = video_id and enabled = 1"

  def initialize
    super(Video)
  end

  def list_status
    render json: VideoStatus.all
  end

  def formatted 
    videos = getFormattedVideos(params[:id])
    if videos.size == 0
      render json: {}
    else
      render json: videos[0]
    end
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

  def search
    @search = Video.search do
      fulltext params[:query], {:fields => [:title, :description, :tags, :category]}
      with :status_id, 2
      with(:category_id).greater_than(1)
      with :parent_video, nil
      order_by :created_at, :desc
    end

    ids = @search.results.map{|v| v["id"]}
    videos = []
    Video.joins(:category).select("videos.id, videos.title, videos.thumbnail, video_categories.name, videos.duration").
        where(id: ids).order(created_at: :desc).each do |v|
      videos << {"id" => v.id, "title" => v.title, "category" => v.name, "thumbnail" => v.thumbnail, "duration" => v.duration}
    end
    render json: videos
  end

  def recent_update
    date = Date.new
    @search = Video.search do
      with :status_id, 2 
      with(:category_id).greater_than(1)
      with :parent_video, nil
      with(:created_at).greater_than(DateTime.now - 10.days)
      order_by :created_at, :desc
    end

    videos = {}
    @search.results.each do |v|
      cat = v["category_id"]
      next if !videos[cat].nil? && videos[cat][1] > v["created_at"]
      videos[cat] = [v["id"], v["created_at"]]
    end

    ids = videos.values.map {|v| v[0]}
    render json: getFormattedVideos(ids)
  end

  def all_videos
    @search = Video.search do
      fulltext '', {:fields => [:title]}
      with :status_id, 2
      with(:category_id).greater_than(1)
      with :parent_video, nil
      order_by :created_at, :desc
      paginate :page => 1, :per_page => 10000
    end

    render json: @search.results.map{|v| v["id"]}
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

  def getFormattedVideos(ids)
    videos = {}
    Video.joins(:category).joins(@@query).select("videos.id, videos.title, videos.description, videos.duration, videos.tags, 
                                                 videos.thumbnail, video_categories.qr_code, video_categories.name,
                                                 video_uploads.host, video_uploads.host_id").
        where(id: ids).where(status_id: 2).where(parent_video: nil).order(created_at: :desc).each do |v|
      id = v.id
      videos[id] = {"id" => id, "title" => v.title, "description" => v.description, "thumbnail" => v.thumbnail, 
                    "duration" => v.duration, "qr_code" => v.qr_code, "category" => v.name, "tags" => JSON.parse(v.tags)} if videos[id].nil?
      if v.host == "youtube"
        videos[id]["youtube_id"] = v.host_id
      elsif v.host == "vimeo"
        videos[id]["vimeo_id"] = v.host_id
      end
    end
    videos.values
  end
end
