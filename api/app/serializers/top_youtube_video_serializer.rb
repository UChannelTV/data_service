class TopYoutubeVideoSerializer < ActiveModel::Serializer
  attributes "id", "created_at", "updated_at"
  
  attribute "tag" do
    (object.tag.nil? || object.tag.strip.empty?) ?  Time.now.strftime("%Y-%m-%d") : object.tag
  end

  attribute "youtube_ids" do
    JSON.parse(object.youtube_ids)
  end

  belongs_to "category" do
    (object.category.nil?) ? nil : object.category.name
  end
end
