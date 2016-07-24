require 'test_helper'

class YoutubeUploadAdminControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success

    assert_equal 100, assigns(:limit)
    assert_not_nil assigns(:records)
    assert_nil flash[:notice]
  end

  test "post index" do
    post :index, {limit: 10}
    assert_response :success

    assert_equal 10, assigns(:limit)
    assert_not_nil assigns(:records)
    assert_nil flash[:notice]
  end
  
  test "get new" do
    get :new
    assert_response :success
    
    assert_not_nil assigns(:record)
    assert_not_nil assigns(:url)
    assert_nil flash[:notice]
  end

  test "delete destroy" do
    target = youtube_uploads(:three)
    delete :destroy, id: target.youtube_id
    assert_redirected_to action: "index"
    assert_not_nil flash[:notice]
    assert flash[:notice].include?("delete")
    
    delete :destroy, id: target.youtube_id
    assert_redirected_to action: "index"
    assert_not_nil flash[:notice]
    assert_not flash[:notice].include?("delete")
  end

  test "post create" do
    target = youtube_uploads(:three)
    test_video = YoutubeUploadSerializer.new(target).as_json
    test_video["youtube_id"] = "new ID"
    post :create, test_video  
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  
    createFail(test_video)

    ["published_at", "title", "thumbnail_small", "thumbnail_medium", "thumbnail_large", "upload_status",
     "privacy_status", "duration"].each do |field|
      video = test_video.clone
      video.delete(field)
      createFail(video) 
    end
  end

  test "get show" do
    get :show, id: youtube_uploads(:one).youtube_id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :show, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "get edit" do
    get :edit, id: youtube_uploads(:one).youtube_id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :edit, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "post update" do
    target = youtube_uploads(:one)
    post :update, {id: target.youtube_id, title: target.title}
    assert_response :success
    assert_not_nil flash[:notice]
    assert_not_nil assigns[:record]
    assert_template :show

    updateFail(target.youtube_id, {duration: 0})
    updateFail(target.youtube_id, {title: ""})
  end
  
  def createFail(video)
    post :create, video
    assert_response :success
    assert_template :new
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  end

  def updateFail(id, video)
    video[:id] = id
    post :update, video
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  end

end
