class YoutubeUpload < ActiveRecord::Base
  validates :published_at, :title, :thumbnail_small, :thumbnail_medium, :thumbnail_large, :upload_status, :privacy_status, presence: true
  validates :duration, numericality: {greater_than: 0, message: "must be a positive interger"} 
  self.primary_key = 'youtube_id'

  def self.external_name
    return "Youtube video"
  end

 def self.external_params(params)
   retVal = params.permit(:youtube_id, :duration, :published_at, :title, :description, :thumbnail_small,
                          :thumbnail_medium, :thumbnail_large, :category_id, :live_broadcast_content,
                          :upload_status, :privacy_status, :embeddable)

   retVal["tags"] = params[:tags]
   if retVal["tags"].nil? 
     retVal["tags"] = []
   elsif retVal["tags"].is_a? String
     retVal["tags"] = retVal["tags"].split(",").map {|x| x.strip}.select {|x| x.size > 0}
   end
   
   retVal["tags"] = retVal["tags"].to_json
   retVal
  end
end
