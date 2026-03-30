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

  # Page titles

  test "blog page has title Blog — Skye" do
    get blog_path
    assert_select "title", text: "Blog — Skye"
  end

  test "post show page title includes post title" do
    get post_path(posts(:one))
    assert_select "title", text: "#{posts(:one).title} — Skye"
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

  # Date archive pages

  test "by_year returns posts for matching year" do
    get posts_by_year_path(year: 2026)
    assert_response :success
    assert_select "a.post-list__title", text: posts(:one).title
  end

  test "by_year returns empty list for year with no posts" do
    get posts_by_year_path(year: 2020)
    assert_response :success
    assert_select "p.post-list__empty"
  end

  test "by_month returns posts for matching year and month" do
    get posts_by_month_path(year: 2026, month: "01")
    assert_response :success
    assert_select "a.post-list__title", text: posts(:one).title
  end

  test "by_month returns empty list for month with no posts" do
    get posts_by_month_path(year: 2026, month: "06")
    assert_response :success
    assert_select "p.post-list__empty"
  end

  test "by_day returns posts for matching date" do
    get posts_by_day_path(year: 2026, month: "01", day: "01")
    assert_response :success
    assert_select "a.post-list__title", text: posts(:one).title
  end

  test "by_day returns empty list for day with no posts" do
    get posts_by_day_path(year: 2026, month: "01", day: "15")
    assert_response :success
    assert_select "p.post-list__empty"
  end

  # Atom feed

  test "feed returns atom content type" do
    get blog_feed_path(format: :atom)
    assert_response :success
    assert_equal "text/xml", response.media_type
  end

  test "feed includes published posts" do
    get blog_feed_path(format: :atom)
    assert_includes response.body, posts(:one).title
  end

  test "feed excludes draft posts" do
    get blog_feed_path(format: :atom)
    assert_not_includes response.body, posts(:two).title
  end

  test "feed is valid atom xml" do
    get blog_feed_path(format: :atom)
    doc = Nokogiri::XML(response.body)
    assert doc.errors.empty?, "Feed XML has errors: #{doc.errors}"
    assert_equal "http://www.w3.org/2005/Atom", doc.root.namespace.href
  end

  test "feed entries include post links" do
    get blog_feed_path(format: :atom)
    doc = Nokogiri::XML(response.body)
    doc.remove_namespaces!
    links = doc.xpath("//entry/link/@href").map(&:value)
    assert_not_empty links
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

  # Tags via form

  test "create assigns tags from tag_names param" do
    sign_in_as(users(:one))
    post posts_path, params: { post: { title: "Tagged Post", body: "Hello", tag_names: "baseball,opera,barack obama" } }
    created = Post.last
    assert_equal 3, created.tags.count
    assert_includes created.tags.map(&:name), "baseball"
    assert_includes created.tags.map(&:name), "opera"
    assert_includes created.tags.map(&:name), "barack obama"
  end

  test "update replaces tags from tag_names param" do
    sign_in_as(users(:one))
    patch post_path(posts(:two)), params: { post: { title: posts(:two).title, tag_names: "jazz,chess" } }
    posts(:two).reload
    assert_equal 2, posts(:two).tags.count
    assert_includes posts(:two).tags.map(&:name), "jazz"
    assert_includes posts(:two).tags.map(&:name), "chess"
  end

  # Tags in views

  test "show displays tags inline with date when post has tags" do
    get post_path(posts(:one))
    assert_select "p.post__meta", text: /ruby/
    assert_select "p.post__meta", text: /rails/
  end

  test "show omits tags from meta when post has no tags" do
    get post_path(posts(:two))
    assert_select "p.post__meta", text: /ruby/, count: 0
  end

  test "archive list displays tags inline with date for tagged posts" do
    get posts_by_year_path(year: 2026)
    assert_select "span.post-list__date", text: /ruby/
  end

  test "blog page displays tags inline with date for tagged posts" do
    get blog_path
    assert_select "span.post-list__date", text: /ruby/
  end

  # Tag index

  test "tags_index lists all tags with post counts" do
    get blog_tags_path
    assert_response :success
    assert_select "a.post-list__title", text: "ruby"
    assert_select "a.post-list__title", text: "rails"
    assert_select "span.post-list__date", text: /1 post/
  end

  test "tags_index shows empty message when no tags exist" do
    Tagging.delete_all
    Tag.delete_all
    get blog_tags_path
    assert_response :success
    assert_select "p.post-list__empty"
  end

  test "tags_index only counts published posts" do
    # posts(:two) is a draft; ruby tag is on posts(:one) which is published
    get blog_tags_path
    assert_select "a.post-list__title", text: "ruby"
  end

  # Tag show

  test "tags_show lists posts for a tag" do
    get blog_tag_path("ruby")
    assert_response :success
    assert_select "h1.page-content__title", text: "ruby"
    assert_select "a.post-list__title", text: posts(:one).title
  end

  test "tags_show returns 404 for unknown tag" do
    get blog_tag_path("nonexistent")
    assert_response :not_found
  end

  test "tags_show excludes draft posts" do
    get blog_tag_path("ruby")
    assert_select "a.post-list__title", text: posts(:two).title, count: 0
  end
end
