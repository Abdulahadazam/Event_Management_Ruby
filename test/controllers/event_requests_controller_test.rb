require "test_helper"

class EventRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get event_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get event_requests_create_url
    assert_response :success
  end

  test "should get show" do
    get event_requests_show_url
    assert_response :success
  end

  test "should get index" do
    get event_requests_index_url
    assert_response :success
  end
end
