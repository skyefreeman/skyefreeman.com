require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page has title Skye" do
    get root_path
    assert_select "title", text: "Skye"
  end

  test "about page has title About — Skye" do
    get about_path
    assert_select "title", text: "About — Skye"
  end

  test "projects page has title Projects — Skye" do
    get projects_path
    assert_select "title", text: "Projects — Skye"
  end

  test "home page displays tags as links" do
    get root_path
    assert_select "span.post-list__date a.post__tag-link", text: "ruby"
  end
end
