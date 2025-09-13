require "test_helper"

class Api::SyncControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_sync_create_url
    assert_response :success
  end

  test "should get status" do
    get api_sync_status_url
    assert_response :success
  end
end
