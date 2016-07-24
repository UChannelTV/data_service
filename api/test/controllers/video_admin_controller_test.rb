require 'test_helper'

class VideoAdminControllerTest < ActionController::TestCase
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
    target = videos(:test2)
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
    target = videos(:test2)
    delete :destroy, id: target.id

    video = VideoSerializer.new(target).as_json
    video.delete("id")
    video.delete("created_at")
    video.delete("updated_at")

    post :create, video  
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  
    createFail(video)

    tv = video.clone
    tv["category"] = "Invalid category"
    createFail(tv)

    tv = video.clone
    tv["status"] = "Invalid status"
    createFail(tv)   
  end

  test "get show" do
    get :show, id: videos(:one).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :show, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "get edit" do
    get :edit, id: videos(:one).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :edit, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "post update" do
    target = videos(:test1)
    post :update, id: target.id, youtube_upload: {title: target.title}
    assert_response :success
    assert_not_nil flash[:notice]
    assert_not_nil assigns[:record]
    assert_template :show

    updateFail(target.id, {"title" => ""})
    updateFail(target.id, {status: "Invalid status"})
    updateFail(target.id, {category: "Invalid category"})
  end
  
  def createFail(video)
    post :create, video
    assert_response :success
    assert_template :new
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  end

  def updateFail(id, video)
    video["id"] = id
    post :update, video
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  end
end
