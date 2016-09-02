class VimeoUploadAdminController < AdminController
  def initialize
    super(VimeoUpload, VimeoUploadSerializer)
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
