require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:two).id
  end

  test "get index" do
    get :index
    assert_response :success

    assert_not_nil assigns(:records)
    assert_nil flash[:notice]
  end
  
  test "get show" do
    get :show, id: users(:one).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :show, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "get edit" do
    get :edit, id: users(:test1).id
    assert_response :success
    assert_nil flash[:notice]
    assert_not_nil assigns(:record)

    get :edit, id: "invalid_id"
    assert_response :success
    assert_not_nil flash[:notice]
    assert_nil assigns(:record)
  end

  test "post update" do
    target = users(:test2)
    post :update, {id: target.id, admin: true}
    assert_response :success
    assert_not_nil flash[:notice]
    assert_not_nil assigns[:record]
    assert_template :show
  end
end 
