class VimeoUpload < ActiveRecord::Base
  validates :published_at, :title, :thumbnail_small, :thumbnail_medium, :thumbnail_large, presence: true
  validates :duration, numericality: {greater_than: 0, message: "must be a positive interger"} 
  self.primary_key = 'vimeo_id'

  def self.external_name
    return "Vimeo video"
  end

  def self.external_params(params)
    retVal = params.permit(:vimeo_id, :duration, :published_at, :title, :description, :thumbnail_small,
                           :thumbnail_medium, :thumbnail_large, :width, :height, :embed_privacy,
                           :channel_id, :expired)

    retVal["tags"] = params[:tags]
    if retVal["tags"].nil? 
      retVal["tags"] = []
    elsif retVal["tags"].is_a? String
      retVal["tags"] = retVal["tags"].split(",").map {|x| x.strip}.select {|x| x.size > 0}
    end
   
    retVal["tags"] = retVal["tags"].to_json
    retVal
  end
  
  def toUChannelVideo
    {"duration" => duration, "created_at" => published_at, "title" => title, "description" => description,
     "thumbnail" => thumbnail_medium, "tags" => JSON.parse(tags).join(",")}
  end
end
