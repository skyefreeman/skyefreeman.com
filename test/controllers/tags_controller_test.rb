require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  # Index

  test "index is accessible without authentication" do
    get tags_path
    assert_response :success
  end

  test "index lists all tags as links" do
    get tags_path
    assert_select "a.post-list__title", text: tags(:ruby).name
    assert_select "a.post-list__title", text: tags(:rails).name
  end

  test "index shows empty state when no tags exist" do
    Tag.destroy_all
    get tags_path
    assert_select "p.post-list__empty"
  end

  # Show

  test "show lists posts for a tag" do
    get tag_path("ruby")
    assert_response :success
    assert_select "h1.page-content__title", text: "ruby"
    assert_select "a.post-list__title", text: posts(:one).title
  end

  test "show returns 404 for unknown tag" do
    get tag_path("nonexistent")
    assert_response :not_found
  end

  test "show excludes draft posts" do
    get tag_path("ruby")
    assert_select "a.post-list__title", text: posts(:two).title, count: 0
  end
end
