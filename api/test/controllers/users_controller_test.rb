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
  
  test "get new" do
    get :new
    assert_response :success
    
    assert_not_nil assigns(:record)
    assert_not_nil assigns(:url)
    assert_nil flash[:notice]
  end

  test "delete destroy" do
    target = users(:test2)
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
    target = users(:test2)
    delete :destroy, id: target.id

    cat = {"name" => "", "password": "MyString", "admin": false} 
    createFail(cat)
    cat = {"name" => target.name, "password": "", "admin": false} 
    createFail(cat)
   
    cat = {"name" => target.name, "password": "MyString" , "admin": false}    

    post :create, cat
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
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
  
  def createFail(user)
    post :create, user
    assert_response :success
    assert_template :new
    assert_not_nil assigns(:record)
    assert_not_nil flash[:notice]
  end
end
