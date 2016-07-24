class YoutubeUploadAdminController < AdminController
  def initialize
    super(YoutubeUpload, YoutubeUploadSerializer)
  end

  def index
    super("published_at", :desc)
  end

  def convert(record)
    retVal = super(record)
    retVal["tags"] = retVal["tags"].join(",") if !retVal.nil?
    retVal
  end
end
