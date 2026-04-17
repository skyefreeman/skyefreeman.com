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

  test "show is accessible without authentication" do
    get tag_path("ruby")
    assert_response :success
  end

  test "show displays the tag name as heading" do
    get tag_path("ruby")
    assert_select "h1.page-content__title", text: "Tag: ruby"
  end

  test "show lists tagged posts" do
    get tag_path("ruby")
    assert_select "a.post-list__title", text: posts(:one).title
  end

  test "show excludes draft posts" do
    get tag_path("ruby")
    assert_select "a.post-list__title", text: posts(:two).title, count: 0
  end

  test "show lists tagged notes" do
    get tag_path("ruby")
    assert_select "a.post-list__title", text: notes(:one).title
  end

  test "show lists tagged links" do
    get tag_path("ruby")
    assert_select "a.post-list__title", text: links(:one).title
  end

  test "show lists tagged ideas" do
    get tag_path("rails")
    assert_select "span.post-list__title", text: ideas(:one).title
  end

  test "show returns 404 for unknown tag" do
    get tag_path("nonexistent")
    assert_response :not_found
  end

  test "show shows empty state when tag has no content" do
    tag = Tag.create!(name: "empty-tag")
    get tag_path(tag.name)
    assert_select "p.post-list__empty"
  end
end
