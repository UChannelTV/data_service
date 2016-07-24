class YoutubeUploadSerializer < ActiveModel::Serializer
  attributes "youtube_id", "title", "description", "duration", "published_at", "category_id",
             "created_at", "updated_at", "thumbnail_small", "thumbnail_medium", "thumbnail_large",
             "live_broadcast_content", "upload_status", "privacy_status", "embeddable"

  attribute "tags" do
    (object.tags.nil?) ? [] : JSON.parse(object.tags)
  end
end
