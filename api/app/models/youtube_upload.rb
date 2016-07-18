class YoutubeUpload < ActiveRecord::Base
  self.primary_key = 'youtube_id'

  def display_array
    retVal = []
    retVal << ["UChannel ID", uchannel_id]
    retVal << ["Youtube ID", youtube_id]
    retVal << ["Duration",  "%d:%02d" % [duration/60, duration%60]]
    retVal << ["Published At", published_at]
    retVal << ["Title", title]
    retVal << ["Description", description]
    retVal << ["Tags", tags]
    retVal << ["Category ID", category_id]
    retVal << ["Live Broadcast Content", live_broadcast_content]
    retVal << ["Upload Status", upload_status]
    retVal << ["Privacy Status", privacy_status]
    retVal << ["Embeddable", embeddable]
    retVal << ["Thumbnail Small", "<a href='#{thumbnail_small}'/>"]
    retVal << ["Thumbnail Medium", "<img src='#{thumbnail_medium}'/>"]
    retVal << ["Thumbnail Large", "<img src='#{thumbnail_large}'/>"]
    retVal
  end

  def self._find(id)
    retVal = find_by youtube_id: id
    return _no_video(id) if retVal.nil?
    return [retVal, nil, 200]
  end

  def self._create(params)
    video =  YoutubeUpload.new(params)
    begin
      if video.save
        return [video, "Youtube video #{video.youtube_id} was created", 201]
      else
        return [video, video.errors, 422]
      end
    rescue ActiveRecord::RecordNotUnique
      return _duplicate_video(video)
    end
  end

  def self._update(id, params)
    video = find_by youtube_id: id
    return _no_video(id) if video.nil?
    params["tags"] = "[]" if (!params["tags"].nil?) && params["tags"] == "null"
    params.delete("uchannel_id") if (!params["uchannel_id"].nil?) && params["uchannel_id"].strip == ""
    if video.update(params)
      return [video, "Youtube video #{id} was updated", 200]
    else
      return [video, video.errors, 422]
    end
  end

  def self._destroy(id)
    video = find_by youtube_id: id
    return _no_video(id) if video.nil?
    video.destroy
    return [nil, "Filler video #{id} was deleted", 200]
  end

  private
    def YoutubeUpload._no_video(id)
      [nil, "Cannot find youtube video #{id}", 400]
    end

    def YoutubeUpload._duplicate_video(video)
      [video, "Video already exisits", 422]
    end
end
