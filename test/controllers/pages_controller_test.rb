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

  test "home page displays post excerpt" do
    get root_path
    assert_select "p.post-list__excerpt"
  end

  test "navigation links to audio samples before games" do
    get root_path

    links = css_select("nav.site-header__nav a.site-header__nav-link")
    audio_index = links.index { |link| link.text == "Audio" }
    games_index = links.index { |link| link.text == "Games" }

    assert_equal audio_samples_path, links[audio_index]["href"]
    assert_operator audio_index, :<, games_index
  end
end
