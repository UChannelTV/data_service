require 'test_helper'

class VideoUploadsControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:two).id
  end

  test "get index" do
    target = [video_uploads(:one), video_uploads(:two)]
    get :index, {video_id: target[0].video_id}
    assert_response :success

    uploads = JSON.parse(@response.body)
    assert_equal 2, uploads.size

    hasOne, hasTwo = false, false

    uploads.each do |upload|
      if upload["id"] == target[0].id
        match_upload(target[0], upload)
        hasOne = true
      elsif upload["id"] == target[1].id
        match_upload(target[1], upload)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
 
    get :index
    assert_response :success
    assert_equal 0, JSON.parse(@response.body).size

    get :index, {host: target[0].host}
    assert_response :success
    assert 0, JSON.parse(@response.body).size
    
    get :index, {host_id: target[0].host_id, host: target[0].host}
    assert_response :success
    assert_equal 1, JSON.parse(@response.body).size
  end

  test "enable" do
    hasOne, hasTwo = false, false
    target = [video_uploads(:one), video_uploads(:two)]
       
    ut = Time.now.to_i
    put :enable, {video_id: target[1].video_id, host: target[1].host, host_id: target[1].host_id}, "CONTENT_TYPE" => 'application/json'
    assert_response :success
   
    get :index, video_id: target[1].video_id
    uploads = JSON.parse(@response.body)
    target[0].enabled, target[1].enabled = false, true
    uploads.each do |upload|
      if upload["id"] == target[0].id
        match_upload(target[0], upload)
        hasOne = true
      elsif upload["id"] == target[1].id
        match_upload(target[1], upload)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
  end

  test "disable" do
    hasOne, hasTwo = false, false
    target = [video_uploads(:one), video_uploads(:two)]
       
    ut = Time.now.to_i
    put :disable, {video_id: target[0].video_id, host: target[0].host, host_id: target[0].host_id}, "CONTENT_TYPE" => 'application/json'
    assert_response :success
   
    get :index, video_id: target[1].video_id
    uploads = JSON.parse(@response.body)
    target[0].enabled, target[1].enabled = false, false
    uploads.each do |upload|
      if upload["id"] == target[0].id
        match_upload(target[0], upload)
        hasOne = true
      elsif upload["id"] == target[1].id
        match_upload(target[1], upload)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
  end

  test "delete" do
    target = video_uploads(:test1)
    delete :destroy, {video_id: target.video_id, host: target.host, host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'
    assert_response :success

    get :index, {host: target.host, host_id: target.host_id}
    assert_equal 0, JSON.parse(@response.body).size

    delete :destroy, video_id: "invalid_id"
    assert_equal "400", @response.code    
  end

  test "create" do
    target = video_uploads(:test1)
    post :create, {video_id: target.video_id, host: target.host, host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code

    delete :destroy, {video_id: target.video_id, host: target.host, host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'

    post :create, {video_id: target.video_id, host: target.host}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code

    post :create, {video_id: target.video_id, host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code

    post :create, {host_id: target.host_id, host: target.host}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code

    post :create, {video_id: target.video_id, host: target.host, host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "201", @response.code

    get :index, {host: target.host, host_id: target.host_id}
    uploads = JSON.parse(@response.body)
    assert_equal 1, uploads.size
    target.enabled = false
    match_upload(target, uploads[0])
  end

  test "put video" do
    target = video_uploads(:test1)
    put :video, {video_id: target.video_id + 1, host: target.host, host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "200", @response.code
    
    get :index, {host: target.host, host_id: target.host_id}
    uploads = JSON.parse(@response.body)
    assert_equal 1, uploads.size
    target.video_id = target.video_id + 1
    match_upload(target, uploads[0])

    put :video, {video_id: target.video_id + 1, host: "Invalid host", host_id: target.host_id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    put :video, {video_id: target.video_id + 1, host: target.host, host_id: "Invalid host id"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
  end


  def match_upload(target, upload)
    assert_equal target.video_id, upload["video_id"]
    assert_equal target.host, upload["host"]
    assert_equal target.host_id, upload["host_id"]
    assert_equal target.enabled, upload["enabled"]
  end
end
