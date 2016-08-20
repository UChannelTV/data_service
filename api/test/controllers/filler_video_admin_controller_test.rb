require 'test_helper'

class FillerVideoAdminControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:two).id
  end

  setup do
    session[:user_id] = users(:two).id
  end

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
    target = filler_videos(:test2)
    delete :destroy, id: target.id
    assert_redirected_to action: "index"
    assert_not_nil flash[:notice]
    assert flash[:notice].include?("delete")
    
    delete :destroy, id: target.id
    assert_redirected_to action: "index"
    assert_not_nil flash[:notice]
    assert_not flash[:notice].include?("delete")
  end

  test "post create" do
    test_video = filler_videos(:test2).as_json
    delete :destroy, id: test_video["id"]

    post :create, test_video  
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]

    createFail(test_video)

    video = test_video.clone
    video["name"] = ""
    createFail(video) 
    
    video = test_video.clone
    video["source"] = ""
    createFail(video)
 
    video = test_video.clone
    video["duration"] = ""
    createFail(video)
  end

  test "get show" do
    get :show, id: filler_videos(:test1).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :show, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "get edit" do
    get :edit, id: filler_videos(:test1).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :edit, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "post update" do
    target = filler_videos(:one)
    post :update, {id: target.id, name: target.name}
    assert_response :success
    assert_not_nil flash[:notice]
    assert_not_nil assigns[:record]
    assert_template :show

    updateFail(target.id, {name: filler_videos(:two).name})
    updateFail(target.id, {duration: 0})
  end
  
  test "get match_search" do
    get :match_search
    assert_response :success 
  end

  test "post match_result" do
    post :match_result, {"duration": 190, "allowed_gap": 0}
    assert_response :success
    assert_not_nil assigns(:videos)
    assert_not_nil assigns(:fields)
    assert_nil flash[:notice]

    post :match_result, {"duration": 0}
    assert_response :success
    assert_nil assigns(:videos)
    assert_nil assigns(:fields)
    assert_not_nil flash[:notice]

    post :match_result, {"duration": 10}
    assert_response :success
    assert_nil assigns(:videos)
    assert_nil assigns(:fields)
    assert_not_nil flash[:notice]
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
