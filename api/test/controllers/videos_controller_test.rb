require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:two).id
  end

  test "get index" do
    get :index
    assert_response :success

    videos = JSON.parse(@response.body)
    assert videos.size >= 2

    hasOne, hasTwo = false, false
    target = [videos(:one), videos(:two)]
    categories = [video_categories(:one), video_categories(:two)]
    statuses = [video_statuses(:one), video_statuses(:two)]

    videos.each do |video|
      if video["id"] == target[0].id
        match_video(target[0], video, categories[0].name, statuses[0].status)
        hasOne = true
      elsif video["id"] == target[1].id
        match_video(target[1], video, nil, statuses[1].status)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
  end

  test "show" do
    target, category, status = videos(:one), video_categories(:one).name, video_statuses(:one).status
    
    get :show, id: target.id
    assert_response :success
    match_video(target, JSON.parse(@response.body), category, status)

    get :show, id: "invalud_id"
    assert_equal "404", @response.code
  end

  test "get list_status" do
    get :list_status
    assert_response :success

    statuses = JSON.parse(@response.body)
    assert statuses.size >= 2

    hasOne, hasTwo = false, false
    target = [video_statuses(:one), video_statuses(:two)]

    statuses.each do |status|
      if status["id"] == target[0].id
        assert_equal status["status"], target[0].status
        hasOne = true
      elsif status["id"] == target[1].id
        assert_equal status["status"], target[1].status
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
  end

  test "update" do
    target = videos(:test1)
    category = video_categories(:two)
    status = video_statuses(:two)
    update = {"duration" => 10, "title" => "New Title", "description" => "New Desc",
              "video_url" => "New URL", "tags" => ["new tag", "new tag2"], :id => target.id,
              "category"=> category.name, "status" => status.status, "other" => "New other"}
   
    ut = Time.now.to_i
    put :update, update, "CONTENT_TYPE" => 'application/json'
    assert_response :success
   
    get :show, id: target.id
    ct = Time.parse(JSON.parse(@response.body)["created_at"]).to_i

    target.duration, target.title, target.description = update["duration"], update["title"], update["description"]
    target.video_url, target.tags, target.other = update["video_url"], update["tags"].to_json, update["other"]  
    get :show, id: target.id
    verify_video(target, target.id, category.name, status.status, [ct, ct + 1], [ut, Time.now.to_i + 1])
  end

  test "update should fail" do
    put :update, {"title": "New Title", id: "invalid_id"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "404", @response.code
    
    target = videos(:test1)
    put :update, {"title" => "", id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    put :update, {status: "Invalid status", id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    put :update, {category: "Invalid category", id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    existing = videos(:one)
    put :update, {"title" => existing.title, "category" => existing.category.name, id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end

  test "delete" do
    target = videos(:test2)
    get :show, id: target.id
    assert_response :success

    delete :destroy, id: target.id
    assert_response :success

    delete :destroy, id: "invalid_id"
    assert_equal "404", @response.code
     
    get :show, id: target.id
    assert_equal "404", @response.code
  end

  test "create" do
    target = videos(:test2)
    delete :destroy, id: target.id
    assert_response :success

    video = VideoSerializer.new(target).as_json
    video.delete("id")
    video.delete("created_at")
    video.delete("updated_at")

    tv = video.clone
    tv.delete("title")
    post :create, tv, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    tv = video.clone
    tv["category"] = "Invalid category"
    post :create, tv, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    tv = video.clone
    tv["status"] = "Invalid status"
    post :create, tv, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
   
    ct = Time.now.to_i
    post :create, video, "CONTENT_TYPE" => 'application/json'
    assert_equal "201", @response.code

    tv = JSON.parse(@response.body)
    verify_video(target, tv["id"], video["category"], video["status"], [ct, ct + 1], [ct, ct + 1])

    post :create, video, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end

  def match_video(target, video, category, status)
    assert_equal target.title, video["title"]
    assert_equal target.description, video["description"]
    assert_equal target.duration, video["duration"]
    assert_equal target.video_url, video["video_url"]
    assert_equal target.other, video["other"]
    assert_equal category, video["category"]
    assert_equal status, video["status"]

    assert_equal JSON.parse(target.tags), video["tags"]
  end

  def verify_video(target, id, category, status, createdAtRange, updatedAtRange)
    assert_response :success
    video = JSON.parse(@response.body)
    assert_equal id, video["id"]
    match_video(target, video, category, status)

    ct = Time.parse(video["created_at"]).to_i
    assert ct >= createdAtRange[0]
    assert ct <= createdAtRange[1]
    ut = Time.parse(video["updated_at"]).to_i
    assert ut >= updatedAtRange[0]
    assert ut <= updatedAtRange[1]
  end

end
