require 'test_helper'

class VideoCategoryAdminControllerTest < ActionController::TestCase
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
    target = video_categories(:test2)
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
    target = video_categories(:test2)
    delete :destroy, id: target.id

    createFail({"name" => target.name})
    createFail({"english_name" => target.english_name})

    cat = {"name" => target.name, "english_name": target.english_name}    
    
    post :create, cat
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  
    createFail(cat)
  end

  test "get show" do
    get :show, id: video_categories(:one).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :show, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "get edit" do
    get :edit, id: video_categories(:test1).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :edit, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "post update" do
    target = video_categories(:test2)
    post :update, {id: target.id, name: target.name}
    assert_response :success
    assert_not_nil flash[:notice]
    assert_not_nil assigns[:record]
    assert_template :show

    updateFail(target.id, {name: video_categories(:two).name})
    updateFail(target.id, {name: ""})
  end
  
  def createFail(cat)
    post :create, cat
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
