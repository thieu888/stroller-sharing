require "test_helper"

class MaintenancesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get maintenances_index_url
    assert_response :success
  end

  test "should get new" do
    get maintenances_new_url
    assert_response :success
  end

  test "should get create" do
    get maintenances_create_url
    assert_response :success
  end
end
