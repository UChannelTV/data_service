require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "get new" do
    get :new
    assert_response :success 
    assert_nil flash[:notice]
  end

  test "delete destroy" do
    session[:user_id] = users(:two).id
    
    delete :destroy
    assert_redirected_to action: "new"
    assert_nil session[:user_id] 
    assert_not_nil flash[:notice]
    assert flash[:notice].include?("You have been logged out")
  end

  test "post create" do
    target = users(:two)
    
    post :create, {"name" => "test2", "password" => ""}
    assert_response :success
    assert_template :new
    assert_nil session[:user_id]
    assert_not_nil flash[:notice]

    post :create, {"name" => "test2", "password" => "test2"}
    assert_equal "302", @response.code    
    assert_redirected_to root_path
    assert_equal target.id, session[:user_id]
    assert_nil flash[:notice]
  end
end
