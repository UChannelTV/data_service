require 'json'

class Video < ActiveRecord::Base
  validates :title, presence: true
  belongs_to :category, class_name: "VideoCategory"
  belongs_to :status, class_name: "VideoStatus"

  def self.external_name
    "Video"
  end

  def self.external_params(params)
    retVal = params.permit(:duration, :title, :description, :video_url, :other, :created_at, :parent_video)
    retVal["tags"] = params[:tags]

    if retVal["tags"].nil? 
     retVal["tags"] = []
    elsif retVal["tags"].is_a? String
     retVal["tags"] = retVal["tags"].split(",").map {|x| x.strip}.select {|x| x.size > 0}
    end
    retVal["tags"] = retVal["tags"].to_json

    if !params["category"].nil?
      cat = VideoCategory.find_by(name: params["category"])
      raise ActiveRecord::ActiveRecordError, "Invalid category '#{params["category"]}'" if cat.nil?
      retVal["category_id"] = cat.id
    end
    
    if !params["status"].nil?
      status = VideoStatus.find_by(status: params["status"])
      raise ActiveRecord::ActiveRecordError, "Invalid status '#{params["status"]}'" if status.nil?
      retVal["status_id"] = status.id
    end

    retVal
  end

  def self._find(category, status, limit)
    return order(created_at: :desc).limit(limit) if category.nil? && status.nil?
    cat_id, s_id = nil, nil
     
    if !category.nil?
      cat = VideoCategory.find_by(name: category)
      return [] if cat.nil?
      cat_id = cat.id
    end

    if !status.nil?
      st = VideoStatus.find_by(status: status)
      return [] if st.nil?
      s_id = st.id
    end

    return where(status_id: s_id).order(created_at: :desc).limit(limit) if cat_id.nil?
    return where(category_id: cat_id).order(created_at: :desc).limit(limit) if s_id.nil?
    return where(category_id: cat_id).where(status_id: s_id).order(created_at: :desc).limit(limit)
  end
end
