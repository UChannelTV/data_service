class VideoAdminController < AdminController
  def initialize
    super(Video, VideoSerializer)
  end

  def index
    @limit, @category, @status = params[:limit].to_i, params[:category], params[:status]
    @limit = 100 if @limit == 0
    @category = nil if @category.eql?("全部")
    @status = nil if @status.eql?("全部")
    
    @records = Video._find(@category, @status, @limit).collect{|x| convert(x)}

    @category = "全部" if @category.nil?
    @status = "全部" if @status.nil?
    
    @categories, @statuses = VideoCategory.all, VideoStatus.all
    allCat = VideoCategory.new
    allCat.name = "全部"
    @categories << allCat

    allS = VideoStatus.new
    allS.status = "全部"
    @statuses << allS
  end

  def new
    super
    host, host_id = params[:source], params[:source_id]
    record = nil
    if host == "vimeo"
      record, msg, code = ModelHandler.new(VimeoUpload).find(host_id)
    elsif host == "youtube"
      record, msg, code = ModelHandler.new(YoutubeUpload).find(host_id)
    end
    @record = record.toUChannelVideo if !record.nil?
  end

  def convert(record)
    retVal = super(record)
    retVal["tags"] = retVal["tags"].join(",") if !retVal.nil?
    retVal
  end
end
