class VideoSerializer < ActiveModel::Serializer
  attributes "id", "title", "description", "duration", "video_url", "created_at", "updated_at", "parent_video", "thumbnail", "other"
  
  attribute "tags" do
    (object.tags.nil? || object.tags.strip.empty?) ? [] : JSON.parse(object.tags)
  end

  belongs_to "status" do
    (object.status.nil?) ? nil : object.status.status
  end

  belongs_to "category" do
    (object.category.nil?) ? nil : object.category.name
  end
end
