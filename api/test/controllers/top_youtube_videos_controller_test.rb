require 'test_helper'

class TopYoutubeVideosControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:two).id
  end

  test "get index" do
    get :index
    assert_response :success

    topVideos = JSON.parse(@response.body)
    assert topVideos.size >= 2

    hasOne, hasTwo = false, false
    target = [top_youtube_videos(:one), top_youtube_videos(:two)]
    category = video_categories(:one).name

    topVideos.each do |top|
      if top["id"] == target[0].id
        match_ids(top, target[0], category)
        hasOne = true
      elsif top["id"] == target[1].id
        match_ids(top, target[1], category)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
  end
  
  test "imported" do
    target = top_youtube_videos(:two)
    get :imported, category: video_categories(:one).name
    assert_response :success
    assert_equal JSON.parse(@response.body), JSON.parse(target.youtube_ids)

    target = top_youtube_videos(:test2)
    get :imported
    assert_response :success
    assert_equal JSON.parse(@response.body), JSON.parse(target.youtube_ids)

    get :imported, category: "invalid cat"
    assert_equal "400", @response.code
    
    get :imported, category: video_categories(:test1).name
    assert_equal "404", @response.code
  end
  
  test "active" do
    target = top_youtube_videos(:one)
    get :active, category: video_categories(:one).name
    assert_response :success
    assert_equal JSON.parse(@response.body), JSON.parse(target.youtube_ids)

    get :active
    assert_equal "404", @response.code

    get :active, category: video_categories(:two).name
    assert_equal "404", @response.code
  end

  test "import" do
    ids = ["aa", "bb"]
    category = video_categories(:one).name
    post "import", {"category": category, "youtube_ids": ids}
    assert_response :success

    get :imported, category: category
    assert_response :success
    assert_equal JSON.parse(@response.body), ids
    
    post "import", "youtube_ids": ids
    assert_response :success

    get :imported
    assert_response :success
    assert_equal JSON.parse(@response.body), ids

    post "import", "category": category
    assert_equal "400", @response.code

    post "import", {"category": "invalid cat", "youtube_ids": ids}
    assert_equal "400", @response.code
  end
  
  test "activate" do
    target = top_youtube_videos("two")
    post "activate", "category": target.category.name
    assert_response :success
    
    get :active, category: target.category.name
    assert_response :success
    assert_equal JSON.parse(@response.body), JSON.parse(target.youtube_ids)
    
    target = top_youtube_videos("test2")
    post "activate"
    assert_response :success
    
    get :active
    assert_response :success
    assert_equal JSON.parse(@response.body), JSON.parse(target.youtube_ids)

    post "activate", "category": "invalid category"
    assert_equal "400", @response.code
    
    post "activate", "category": video_categories(:two).name
    assert_equal "404", @response.code
  end
=begin
    target = top_youtube_videos(:test1)
    tag, category, youtube_ids = "new tag", video_categories(:two).name, ["11", "12"]  
    ut = Time.now.to_i
    put :update, {"tag": tag, "category": category, "youtube_ids": youtube_ids, "id": target.id}, "CONTENT_TYPE" => 'application/json'
    assert_response :success
   
    get :show, id: target.id
    ct = Time.parse(JSON.parse(@response.body)["created_at"]).to_i
    
    target.tag, target.youtube_ids = tag, youtube_ids.to_json
    get :show, id: target.id
    verify_top_videos(target, category, target.id, [ct, ct + 1], [ut, Time.now.to_i + 1])
  end
  
  test "update should fail" do
    target = top_youtube_videos(:test1)
    put :update, {"tag": "tag", id: "invalid_id"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "404", @response.code
    
    put :update, {"tag": "tag", id: target.id, "category": "invalid category"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    existing = top_youtube_videos(:one)

    put :update, {"tag": existing.tag, "category": existing.category.name, "id": target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end
  
  test "delete" do
    target = top_youtube_videos(:test2)
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
    target = top_youtube_videos(:test2)
    delete :destroy, id: target.id
    assert_response :success

    post :create, {"category" => target.category.name}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    ct = Time.now.to_i
    post :create, {"category" => target.category.name, "youtube_ids" => target.youtube_ids}, "CONTENT_TYPE" => 'application/json'
    assert_equal "201", @response.code

    video = JSON.parse(@response.body)
    assert !video["tag"].nil?
    target.tag = video["tag"]
    verify_top_videos(target, video["id"], [ct, ct + 1], [ct, ct + 1])

    post :create, {"target" => target.name, "english_name" => target.english_name, "qr_code" => target.qr_code}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end
=end  
  def match_ids(target, top, category)
    assert_equal JSON.parse(top.youtube_ids), target["youtube_ids"]
    assert_equal target["category"], category
    assert_equal target["tag"], top.tag
  end

  def verify_top_videos(target, category, id, createdAtRange, updatedAtRange)
    assert_response :success
    cat = JSON.parse(@response.body)
    assert_equal id, cat["id"]
    match_ids(cat, target, category)

    ct = Time.parse(cat["created_at"]).to_i
    assert ct >= createdAtRange[0]
    assert ct <= createdAtRange[1]
    ut = Time.parse(cat["updated_at"]).to_i
    assert ut >= updatedAtRange[0]
    assert ut <= updatedAtRange[1]
  end
end
