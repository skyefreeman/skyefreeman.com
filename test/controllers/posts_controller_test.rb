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

  test "new returns a blank post form" do
    get new_post_path
    assert_response :success
  end

  test "create saves a new post and redirects" do
    post posts_path, params: { post: { title: "New Post", author: "Skye", state: "draft", body: "Hello" } }
    assert_redirected_to post_path(Post.last)
  end

  test "edit returns the post form" do
    get edit_post_path(posts(:one))
    assert_response :success
  end

  test "update saves changes and redirects" do
    patch post_path(posts(:one)), params: { post: { title: "Updated Title" } }
    assert_redirected_to post_path(posts(:one))
  end

  test "destroy deletes the post and redirects to index" do
    delete post_path(posts(:one))
    assert_redirected_to posts_path
  end
end
