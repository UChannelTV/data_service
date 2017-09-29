require 'json'
require 'time'

class TopYoutubeVideo < ActiveRecord::Base
  validates :youtube_ids, presence: true
  belongs_to :category, class_name: "VideoCategory"
    
  def self.external_name
    "Top Video"
  end

  def self.external_params(params)
    retVal = params.permit(:tag, :youtube_ids)

    if !params["category"].nil?
      cat = VideoCategory.find_by(name: params["category"])
      raise ActiveRecord::ActiveRecordError, "Invalid category '#{params["category"]}'" if cat.nil?
      retVal["category_id"] = cat.id
    end

    retVal["youtube_ids"] = params[:youtube_ids]
    if retVal["youtube_ids"].is_a? String
     retVal["youtube_ids"] = retVal["youtube_ids"].split(",").map {|x| x.strip}.select {|x| x.size > 0}
    end
    retVal["youtube_ids"] = retVal["youtube_ids"].to_json
    
    retVal["tag"] = Time.now.strftime("%Y-%m-%d") if retVal["tag"].nil?
    retVal
  end

  def self.import_tag
    "staging"
  end

  def self._find(category, tag)
    return where(category_id: nil, tag: tag).limit(1) if category.nil?

    cat = VideoCategory.find_by(name: category)
    return nil if cat.nil?

    return where(category_id: cat.id, tag: tag).order(created_at: :desc).limit(1)
  end

  def self._import(category, youtube_ids)
    return ["Missing youtube IDs", 400] if youtube_ids.nil?
    if category.nil? 
      find_or_create_by(category_id: nil, tag: import_tag).update_attributes({"youtube_ids": youtube_ids})
    else
      cat = VideoCategory.find_by(name: category)
      return ["Invalid category", 400] if cat.nil?

      find_or_create_by(category_id: cat.id, tag: import_tag).update_attributes({"youtube_ids": youtube_ids})
    end
    return [nil, 200]
  end
end
