require 'test_helper'

class VideoUploadAdminControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success

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
    target = video_uploads(:test2)
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
    target = video_uploads(:test2)
    delete :destroy, id: target.id
    upload = {"video_id" => target.video_id, "host" => target.host, "host_id" => target.host_id}

    tv = upload.clone
    tv.delete("video_id")
    createFail(tv)

    tv = upload.clone
    tv.delete("host")
    createFail(tv)

    tv = upload.clone
    tv.delete("host_id")
    createFail(tv)
    
    post :create, upload
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  
    createFail(upload)
  end

  test "get show" do
    get :show, id: video_uploads(:one).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :show, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "get edit" do
    get :edit, id: video_uploads(:test1).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :edit, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "post update" do
    target = video_uploads(:test2)
    post :update, {id: target.id, enabled: target.enabled}
    assert_response :success
    assert_not_nil flash[:notice]
    assert_not_nil assigns[:record]
    assert_template :show
  end
  
  def createFail(upload)
    post :create, upload
    assert_response :success
    assert_template :new
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  end
end
