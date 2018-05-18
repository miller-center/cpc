require 'test_helper'

class PresidentsControllerTest < ActionController::TestCase
  setup do
    @president = presidents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:presidents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create president" do
    assert_difference('President.count') do
      post :create, president: {  }
    end

    assert_redirected_to president_path(assigns(:president))
  end

  test "should show president" do
    get :show, id: @president
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @president
    assert_response :success
  end

  test "should update president" do
    patch :update, id: @president, president: {  }
    assert_redirected_to president_path(assigns(:president))
  end

  test "should destroy president" do
    assert_difference('President.count', -1) do
      delete :destroy, id: @president
    end

    assert_redirected_to presidents_path
  end
end
