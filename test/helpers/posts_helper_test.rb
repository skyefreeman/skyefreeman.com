require "test_helper"

class PostsHelperTest < ActionView::TestCase
  test "post_url_path returns date slug path when post has published_at and url_slug" do
    post = posts(:one)
    assert_equal "/blog/2026/01/01/first-post", post_url_path(post)
  end

  test "post_url_path returns post_path when url_slug is missing" do
    post = posts(:two)
    assert_equal post_path(post), post_url_path(post)
  end

  test "post_url_path returns post_path when published_at is missing" do
    post = Post.new(id: 0, title: "No Date", url_slug: "no-date")
    assert_equal post_path(post), post_url_path(post)
  end
end
