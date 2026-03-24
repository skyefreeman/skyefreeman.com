require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  # Public actions

  test "blog lists all posts" do
    get blog_path
    assert_response :success
  end

  test "show returns a single post" do
    get post_path(posts(:one))
    assert_response :success
  end

  # Draft post visibility

  test "blog hides draft posts from unauthenticated users" do
    get blog_path
    assert_response :success
    assert_select "a.post-list__title", text: posts(:one).title
    assert_select "a.post-list__title", text: posts(:two).title, count: 0
  end

  test "blog shows draft posts to authenticated users" do
    sign_in_as(users(:one))
    get blog_path
    assert_response :success
    assert_select "a.post-list__title", text: posts(:one).title
    assert_select "a.post-list__title", text: posts(:two).title
  end

  # Date/slug lookup

  test "show_by_date_slug finds post when date and slug match" do
    post = posts(:one)
    get post_by_date_slug_path(year: 2026, month: "01", day: "01", slug: "first-post")
    assert_response :success
  end

  test "show_by_date_slug returns 404 when slug matches but date does not" do
    get post_by_date_slug_path(year: 2025, month: "01", day: "01", slug: "first-post")
    assert_response :not_found
  end

  test "show_by_date_slug returns 404 when date matches but slug does not" do
    get post_by_date_slug_path(year: 2026, month: "01", day: "01", slug: "wrong-slug")
    assert_response :not_found
  end

  # Unauthenticated access to write actions redirects to login

  test "new redirects to login when unauthenticated" do
    get new_post_path
    assert_redirected_to new_session_path
  end

  test "create redirects to login when unauthenticated" do
    post posts_path, params: { post: { title: "New Post", body: "Hello" } }
    assert_redirected_to new_session_path
  end

  test "edit redirects to login when unauthenticated" do
    get edit_post_path(posts(:one))
    assert_redirected_to new_session_path
  end

  test "update redirects to login when unauthenticated" do
    patch post_path(posts(:one)), params: { post: { title: "Updated Title" } }
    assert_redirected_to new_session_path
  end

  test "destroy redirects to login when unauthenticated" do
    delete post_path(posts(:one))
    assert_redirected_to new_session_path
  end

  # Authenticated access to write actions succeeds

  test "new returns a blank post form when authenticated" do
    sign_in_as(users(:one))
    get new_post_path
    assert_response :success
  end

  test "create saves a new post and redirects when authenticated" do
    sign_in_as(users(:one))
    post posts_path, params: { post: { title: "New Post", body: "Hello" } }
    assert_redirected_to post_path(Post.last)
  end

  test "edit returns the post form when authenticated" do
    sign_in_as(users(:one))
    get edit_post_path(posts(:one))
    assert_response :success
  end

  test "update saves changes and redirects when authenticated" do
    sign_in_as(users(:one))
    patch post_path(posts(:one)), params: { post: { title: "Updated Title" } }
    assert_redirected_to post_path(posts(:one))
  end

  test "destroy deletes the post and redirects to blog when authenticated" do
    sign_in_as(users(:one))
    delete post_path(posts(:one))
    assert_redirected_to blog_path
  end
end
