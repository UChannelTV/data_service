require 'test_helper'

class VideoCategoriesControllerTest < ActionController::TestCase
  test "get index" do
    get :index
    assert_response :success

    cats = JSON.parse(@response.body)
    assert cats.size >= 2

    hasOne, hasTwo = false, false
    target = [video_categories(:one), video_categories(:two)]
    cats.each do |cat|
      if cat["id"] == target[0].id
        match_category(target[0], cat)
        hasOne = true
      elsif cat["id"] == target[1].id
        match_category(target[1], cat)
        hasTwo = true
      end
    end
    assert hasOne
    assert hasTwo
  end
 
  test "show" do
    target = video_categories(:one)
    get :show, id: target.id
    assert_response :success
    match_category(target, JSON.parse(@response.body))

    get :show, id: "invalud_id"
    assert_equal "404", @response.code
  end

  test "update" do
    target = video_categories(:test1)
    name, ename, qr = "New Name", "New Name2", "New QR"
   
    ut = Time.now.to_i
    put :update, {"name": name, "english_name": ename, "qr_code": qr, id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_response :success
   
    get :show, id: target.id
    ct = Time.parse(JSON.parse(@response.body)["created_at"]).to_i

    target.name, target.english_name, target.qr_code = name, ename, qr
    get :show, id: target.id
    verify_category(target, target.id, [ct, ct + 1], [ut, Time.now.to_i + 1])
  end

  test "update should fail" do
    put :update, {"name": name, id: "invalid_id"}, "CONTENT_TYPE" => 'application/json'
    assert_equal "404", @response.code
    
    target = video_categories(:test1)
    existing = video_categories(:one)

    put :update, {"name" => existing.name, id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
    
    put :update, {"english_name" => existing.english_name, id: target.id}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end

  test "delete" do
    target = video_categories(:test2)
    get :show, id: target.id
    assert_response :success

    delete :destroy, id: target.id
    assert_response :success

    delete :destroy, id: "invalid_id"
    assert_equal "404", @response.code
     
    get :show, id: target.id
    assert_equal "404", @response.code
  end

  test "create" do
    target = video_categories(:test2)
    delete :destroy, id: target.id
    assert_response :success

    post :create, {"name" => target.name, "qr_code" => target.qr_code}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    post :create, {"english_name" => target.english_name, "qr_code" => target.qr_code}, "CONTENT_TYPE" => 'application/json'
    assert_equal "400", @response.code
    
    ct = Time.now.to_i
    post :create, {"name" => target.name, "english_name" => target.english_name, "qr_code" => target.qr_code}, "CONTENT_TYPE" => 'application/json'
    assert_equal "201", @response.code

    video = JSON.parse(@response.body)
    verify_category(target, video["id"], [ct, ct + 1], [ct, ct + 1])

    post :create, {"name" => target.name, "english_name" => target.english_name, "qr_code" => target.qr_code}, "CONTENT_TYPE" => 'application/json'
    assert_equal "409", @response.code
  end
  
def match_category(target, category)
    assert_equal target.name, category["name"]
    assert_equal target.english_name, category["english_name"]
    assert_equal target.qr_code, category["qr_code"]
  end

  def verify_category(target, id, createdAtRange, updatedAtRange)
    assert_response :success
    cat = JSON.parse(@response.body)
    assert_equal id, cat["id"]
    match_category(target, cat)

    ct = Time.parse(cat["created_at"]).to_i
    assert ct >= createdAtRange[0]
    assert ct <= createdAtRange[1]
    ut = Time.parse(cat["updated_at"]).to_i
    assert ut >= updatedAtRange[0]
    assert ut <= updatedAtRange[1]
  end
end
