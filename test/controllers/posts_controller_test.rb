require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "index returns all posts" do
    get posts_path
    assert_response :success
  end

  test "show returns a single post" do
    get post_path(posts(:one))
    assert_response :success
  end
end
