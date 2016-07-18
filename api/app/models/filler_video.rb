class FillerVideo < ActiveRecord::Base

  def display_array
    retVal = []
    retVal << ["ID", id]
    retVal << ["Name", name]
    retVal << ["Source", source]
    retVal << ["Duration",  "%d:%02d" % [length/60, length%60]]
    retVal << ["Expired", expired]
    retVal << ["Created At", created_at]
    retVal << ["Updated At", updated_at]
    retVal
  end

  def self._create(params)
    video =  FillerVideo.new(params)
    begin
      if video.save
        return [video, "Filler video #{video.id} was created", 201]
      else
        return [video, video.errors, 422]
      end
    rescue ActiveRecord::RecordNotUnique
      return _duplicate_video(video)
    end  
  end

  def self._find(id)
    begin
      return [find(id), nil, 200]
    rescue ActiveRecord::RecordNotFound
      return _no_video(id)
    end
  end

  def self._update(id, params)
    begin
      video = find(id)
      if video.update(params)
        return [video, "Filler video #{id} was updated", 200]
      else
        return [video, video.errors, 422]
      end
    rescue ActiveRecord::RecordNotUnique
      return _duplicate_video(video)
    rescue ActiveRecord::RecordNotFound
      return _no_video(id)
    end  
  end

  def self._destroy(id)
    begin
      video = find(id)
      video.destroy
      return [nil, "Filler video #{id} was deleted", 200]
    rescue ActiveRecord::RecordNotFound
      return _no_video(id)
    end
  end

  private

  def self._no_video(id)
     [nil, "Cannot find filler video #{id}", 400]
  end

  def self._duplicate_video(video)
    [video, "There is another filler video with the same name and source", 422]
  end
end
