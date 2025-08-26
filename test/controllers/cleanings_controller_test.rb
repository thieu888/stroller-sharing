require "test_helper"

class CleaningsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cleanings_index_url
    assert_response :success
  end

  test "should get new" do
    get cleanings_new_url
    assert_response :success
  end

  test "should get create" do
    get cleanings_create_url
    assert_response :success
  end
end
