require 'test_helper'

class FillerVideosControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success

    videos = JSON.parse(@response.body)
    assert videos.size >= 5

    hasOne, hasFour = false, false
    target = [filler_videos(:one), filler_videos(:four)]
    videos.each do |video|
      if video["name"] == target[0].name && video["source"] == target[0].source
        match_video(target[0], video)
        hasOne = true
      elsif video["name"] == target[1].name && video["source"] == target[1].source
        match_video(target[1], video)
        hasFour = true
      end
    end
    assert hasOne
    assert hasFour

    get :index, limit: 2
    assert_response :success

    videos = JSON.parse(@response.body)
    assert_equal 2, videos.size
  end
  
  test "show" do
    target = filler_videos(:one)
    get :show, id: target.id
    assert_response :success
    match_video(target, JSON.parse(@response.body))

    target = filler_videos(:one)
    get :show, id: "invalud_id"
    assert_equal "404", @response.code
  end

  test "update" do
    target = filler_videos(:test1)
    dur, expired = target.duration + 10, !target.expired
    ut = Time.now.to_i
    put :update, {"expired": expired, "duration": dur, id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_response :success
   
    get :show, id: target.id
    ct = Time.parse(JSON.parse(@response.body)["created_at"]).to_i

    target.duration, target.expired = dur, expired
    get :show, id: target.id
    verify_video(target, target.id, [ct, ct + 1], [ut, Time.now.to_i + 1])

    put :update, {"expired": expired, "duration": dur, id: "invalid_id"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "404", @response.code
    
    put :update, {"duration" => 0, id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
  end

  test "delete" do
    target = filler_videos(:test2)
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
    target = filler_videos(:test2)
    delete :destroy, id: target.id

    post :create, {"name" => target.name, "source" => target.source}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    post :create, {"name" => target.name, "duration" => target.duration}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    post :create, {"duration" => target.duration, "source" => target.source}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    post :create, {"name" => target.name, "duration" => 0, "source" => target.source}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code

    ct = Time.now.to_i
    post :create, {name: target.name, source: target.source, duration: target.duration}, "CONTENT_TYPE" => 'application/json'
    assert_equal "201", @response.code

    video = JSON.parse(@response.body)
    target.video_url = nil
    target.expired = false 
    verify_video(target, video["id"], [ct, ct + 1], [ct, ct + 1])

    post :create, {name: target.name, source: target.source, duration: target.duration}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end
    
  test "find" do
    get :find, {"duration": 190, "allowed_gap": 0}                                             
    assert_response :success
    
    matches = JSON.parse(@response.body)
    assert_equal 1, matches.size
    assert matches.has_key?("0")

    hasVideos = false
    matches["0"].each do |m|
      next if m.size != 2
      if m[0]["name"] == "MyName3" && m[1]["name"] == "MyName2"
        hasVideos = true
        break
      end
      if m[0]["name"] == "MyName2" && m[1]["name"] == "MyName3"
        hasVideos = true
        break
      end
    end
    assert hasVideos

    get :find, {"duration": 10}                                             
    verify_matches([], 0)

    get :find, {"duration": 190, "min_candidate": 2}                                             
    verify_matches(["0", "-2"], 3)

    get :find, {"duration": 190, "min_candidate": 2, "max_candidate": 2}
    verify_matches(["0", "-2"], 2)
    
    get :find, {"duration": 190, "min_candidate": 5, "allowed_gap": 11}                                          
    verify_matches(["0", "-2", "10"], 4)

    get :find, {"duration": 190, "min_candidate": 6, "allowed_gap": 11, "allow_duplicate": "true"}                                          
    verify_matches(["0", "-2", "10"], 6)
  end

  test "find bad request" do
    get :find, {"duration": 0}
    assert_equal "400", @response.code

    get :find, {"duration": 100, "min_candidate": 0}
    assert_equal "400", @response.code

    get :find, {"duration": 100, "min_candidate": 3, "max_candidate": 2}
    assert_equal "400", @response.code

    get :find, {"duration": 100, "min_candidate": 3, "max_candidate": 10, "allowed_gap": -1}
    assert_equal "400", @response.code
  end
 
  def match_video(target, video)
    assert_equal target.name, video["name"]
    assert_equal target.source, video["source"]
    assert_equal target.duration, video["duration"]
    assert_equal target.video_url, video["video_url"]
    assert_equal target.expired, video["expired"]
  end

  def verify_video(target, id, createdAtRange, updatedAtRange)
    assert_response :success
    video = JSON.parse(@response.body)
    assert_equal id, video["id"]
    match_video(target, video)

    ct = Time.parse(video["created_at"]).to_i
    assert ct >= createdAtRange[0]
    assert ct <= createdAtRange[1]
    ut = Time.parse(video["updated_at"]).to_i
    assert ut >= updatedAtRange[0]
    assert ut <= updatedAtRange[1]
  end

  def verify_matches(keys, numMatches)
    assert_response :success

    matches = JSON.parse(@response.body)
    assert_equal keys.size, matches.size

    num = 0
    keys.each do |key|
      assert matches.has_key?(key)
      num += matches[key].size
    end
    assert_equal num, numMatches
  end
end
