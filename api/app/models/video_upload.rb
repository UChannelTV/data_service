class VideoUpload < ActiveRecord::Base
  validates :video_id, :host, :host_id, presence: true
 
  def self.external_name
    "Video Upload"
  end

  def self.external_params(params)
    retVal = params.permit(:video_id, :host, :host_id, :enabled)
    retVal["enabled"] = false if retVal["enabled"].nil?
    return retVal
  end

  def self.enable(host, host_id)
    ActiveRecord::Base.transaction do
      upload = _findUnique(host, host_id).first
      return no_upload(host, host_id) if upload.nil?
      where(video_id: upload.video_id).where(host: host).where.not(host_id: host_id).update_all(enabled: false)
      where(host: host).where(host_id: host_id).update_all(enabled: true)
    end
    ["Video upload (#{host}, #{host_id}) was enabled", 200]
  end

  def self.disable(host, host_id)
    upload = _findUnique(host, host_id).first
    return no_upload(video_id, host, host_id) if upload.nil?
    where(host: host).where(host_id: host_id).update_all(enabled: false)
    ["Video upload (#{host}, #{host_id}) was disabled", 200]
  end

  def self._destroy(host, host_id)
    upload = _findUnique(host, host_id).first
    return no_upload(host, host_id) if upload.nil?
    where(host: host).where(host_id: host_id).delete_all
    ["Video upload (#{host}, #{host_id}) was deleted", 200]
  end

  def self._find(video_id, host, host_id)
    if video_id.nil?
      return _findUnique(host, host_id)
    else
      return where(video_id: video_id).order(:id)
    end
  end

  def self._findUnique(host, host_id)
    return VideoUpload.where(host: host).where(host_id: host_id)
  end

  def self._setVideoID(video_id, host, host_id)
    upload = _findUnique(host, host_id).first
    return no_upload(host, host_id) if upload.nil?
    where(host: host).where(host_id: host_id).update_all(video_id: video_id)
    return ["Update video ID succeeded", 200]
  end

  private
    def self.no_upload(host, host_id)
      ["Cannot find video upload (#{host}, #{host_id})", 400]
    end
end
