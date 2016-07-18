require 'test_helper'

class UchannelVideosControllerTest < ActionController::TestCase
  setup do
    @uchannel_video = uchannel_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:uchannel_videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create uchannel_video" do
    assert_difference('UchannelVideo.count') do
      post :create, uchannel_video: { category: @uchannel_video.category, created_at: @uchannel_video.created_at, description: @uchannel_video.description, duration: @uchannel_video.duration, status: @uchannel_video.status, tags: @uchannel_video.tags, title: @uchannel_video.title, video_url: @uchannel_video.video_url }
    end

    assert_redirected_to uchannel_video_path(assigns(:uchannel_video))
  end

  test "should show uchannel_video" do
    get :show, id: @uchannel_video
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @uchannel_video
    assert_response :success
  end

  test "should update uchannel_video" do
    patch :update, id: @uchannel_video, uchannel_video: { category: @uchannel_video.category, created_at: @uchannel_video.created_at, description: @uchannel_video.description, duration: @uchannel_video.duration, status: @uchannel_video.status, tags: @uchannel_video.tags, title: @uchannel_video.title, video_url: @uchannel_video.video_url }
    assert_redirected_to uchannel_video_path(assigns(:uchannel_video))
  end

  test "should destroy uchannel_video" do
    assert_difference('UchannelVideo.count', -1) do
      delete :destroy, id: @uchannel_video
    end

    assert_redirected_to uchannel_videos_path
  end
end
