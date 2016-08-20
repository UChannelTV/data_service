require 'test_helper'

class YoutubeUploadsControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:two).id
  end

  test "get index" do
    get :index
    assert_response :success
    videos = JSON.parse(@response.body)
    assert videos.size >= 2

    hasOne, hasTwo = false, false
    target = [youtube_uploads(:one), youtube_uploads(:two)]
    videos.each do |video|
      if video["youtube_id"] == target[0].youtube_id
        match_video(target[0], video)
        hasOne = true
      elsif video["youtube_id"] == target[1].youtube_id
        match_video(target[1], video)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
    
    get :index, limit: 1
    assert_response :success

    videos = JSON.parse(@response.body)
    assert_equal 1, videos.size
  end
 
  test "show" do
    target = youtube_uploads(:one)
    get :show, id: target.id
    assert_response :success
    match_video(target, JSON.parse(@response.body))
  end

  test "show should fail" do
    get :show, id: "invalud_id"
    assert_equal "404", @response.code
  end

  test "update" do
    source = youtube_uploads(:three)
    video = YoutubeUploadSerializer.new(source).as_json
    video.delete("youtube_id")
    target = youtube_uploads(:four)

    video[:id] = target.youtube_id
    ut = Time.now.to_i
    put :update, video, "CONTENT_TYPE" => 'application/json'
    assert_response :success
  
    ct = target.created_at.to_i
    get :show, id: target.youtube_id
    source.youtube_id = target.youtube_id
    verify_video(source, target.youtube_id, [ct, ct + 1], [ut, Time.now.to_i + 1])
  end

  test "update should fail" do
    put :update, {"title" => "new title", id: "invalid_id"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "404", @response.code
    
    target = youtube_uploads(:three)
    put :update, {"duration" => 0, id: target.youtube_id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
  end

  test "delete" do
    target = youtube_uploads(:three)
    get :show, id: target.youtube_id
    assert_response :success

    delete :destroy, id: target.youtube_id
    assert_response :success

    delete :destroy, id: "invalid_id"
    assert_equal "404", @response.code
     
    get :show, id: target.youtube_id
    assert_equal "404", @response.code
  end

  test "create should fail" do
    video = YoutubeUploadSerializer.new(youtube_uploads(:three)).as_json

    ["published_at", "title", "thumbnail_small", "thumbnail_medium", "thumbnail_large", "upload_status",
     "privacy_status", "duration"].each do |field|
      tv = video.clone
      tv.delete(field)
      post :create, tv, "CONTENT_TYPE" => 'application/json'
      assert_equal "400", @response.code
    end

    post :create, video, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end

  test "create" do
    target = youtube_uploads(:three)
    delete :destroy, id: target.youtube_id
    assert_response :success

    video = YoutubeUploadSerializer.new(target).as_json

    ct = Time.now.to_i
    post :create, video, "CONTENT_TYPE" => 'application/json'
    assert_equal "201", @response.code
 
    verify_video(target, target.youtube_id, [ct, ct + 1], [ct, ct + 1])
  end
  
  private

  def verify_video(target, id, createdAtRange, updatedAtRange)
    assert_response :success
    video = JSON.parse(@response.body)
    assert_equal id, video["youtube_id"]
    match_video(target, video)

    ct = Time.parse(video["created_at"]).to_i
    assert ct >= createdAtRange[0]
    assert ct <= createdAtRange[1]
    ut = Time.parse(video["updated_at"]).to_i
    assert ut >= updatedAtRange[0]
    assert ut <= updatedAtRange[1]
  end

  def match_video(target, video)
    tv = YoutubeUploadSerializer.new(target).as_json
    ["youtube_id", "duration", "titie", "description", "thumbnail_small", "thumbnail_medium",
     "thumbnail_large", "category_id", "live_broadcast_content", "upload_status",
     "privacy_status", "embeddable"].each do |field|
      assert_equal tv[field], video[field]
    end

    assert_equal tv["published_at"].to_i, Time.parse(video["published_at"]).to_i
    assert_equal JSON.parse(target["tags"]), video["tags"]
  end

end
