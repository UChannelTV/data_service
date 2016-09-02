class VimeoUploadSerializer < ActiveModel::Serializer
  attributes "vimeo_id", "title", "description", "duration", "published_at", "channel_id",
             "created_at", "updated_at", "thumbnail_small", "thumbnail_medium", "thumbnail_large",
             "width", "height", "embed_privacy", "expired"

  attribute "tags" do
    (object.tags.nil?) ? [] : JSON.parse(object.tags)
  end
end
