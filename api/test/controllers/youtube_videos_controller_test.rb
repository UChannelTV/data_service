require 'test_helper'

class YoutubeVideosControllerTest < ActionController::TestCase
  setup do
    @youtube_video = youtube_videos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:youtube_videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create youtube_video" do
    assert_difference('YoutubeVideo.count') do
      post :create, youtube_video: { categoryId: @youtube_video.categoryId, description: @youtube_video.description, duration: @youtube_video.duration, embeddable: @youtube_video.embeddable, liveBroadcastContent: @youtube_video.liveBroadcastContent, privacyStatus: @youtube_video.privacyStatus, published_at: @youtube_video.published_at, tags: @youtube_video.tags, thumbnail_large: @youtube_video.thumbnail_large, thumbnail_medium: @youtube_video.thumbnail_medium, thumbnail_small: @youtube_video.thumbnail_small, title: @youtube_video.title, uchannel_id: @youtube_video.uchannel_id, uploadStatus: @youtube_video.uploadStatus, youtube_id: @youtube_video.youtube_id }
    end

    assert_redirected_to youtube_video_path(assigns(:youtube_video))
  end

  test "should show youtube_video" do
    get :show, id: @youtube_video
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @youtube_video
    assert_response :success
  end

  test "should update youtube_video" do
    patch :update, id: @youtube_video, youtube_video: { categoryId: @youtube_video.categoryId, description: @youtube_video.description, duration: @youtube_video.duration, embeddable: @youtube_video.embeddable, liveBroadcastContent: @youtube_video.liveBroadcastContent, privacyStatus: @youtube_video.privacyStatus, published_at: @youtube_video.published_at, tags: @youtube_video.tags, thumbnail_large: @youtube_video.thumbnail_large, thumbnail_medium: @youtube_video.thumbnail_medium, thumbnail_small: @youtube_video.thumbnail_small, title: @youtube_video.title, uchannel_id: @youtube_video.uchannel_id, uploadStatus: @youtube_video.uploadStatus, youtube_id: @youtube_video.youtube_id }
    assert_redirected_to youtube_video_path(assigns(:youtube_video))
  end

  test "should destroy youtube_video" do
    assert_difference('YoutubeVideo.count', -1) do
      delete :destroy, id: @youtube_video
    end

    assert_redirected_to youtube_videos_path
  end
end
