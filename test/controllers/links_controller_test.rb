require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @link = links(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get links_url
    assert_response :success
  end

  test "index is accessible without authentication" do
    get links_url
    assert_response :success
  end

  test "index renders title as link text when title is present" do
    get links_url
    assert_select "a[href='#{links(:one).url}']", text: links(:one).title
  end

  test "index renders url as link text when title is absent" do
    get links_url
    assert_select "a[href='#{links(:two).url}']", text: links(:two).url
  end

  test "should get new" do
    get new_link_url
    assert_response :success
  end

  test "should create link" do
    assert_difference("Link.count") do
      post links_url, params: { link: { url: @link.url } }
    end

    assert_redirected_to links_url
  end

  test "should show link" do
    get link_url(@link)
    assert_response :success
  end

  test "should get edit" do
    get edit_link_url(@link)
    assert_response :success
  end

  test "should update link" do
    patch link_url(@link), params: { link: { url: @link.url } }
    assert_redirected_to links_url
  end

  test "should destroy link" do
    assert_difference("Link.count", -1) do
      delete link_url(@link)
    end

    assert_redirected_to links_url
  end

  test "create saves tags when tag_names param is provided" do
    post links_url, params: { link: { url: "https://new.com", tag_names: "ruby, elixir" } }
    assert_equal 2, Link.last.tags.count
  end

  test "update saves tags when tag_names param is provided" do
    patch link_url(@link), params: { link: { tag_names: "elixir" } }
    assert_includes @link.reload.tags.map(&:name), "elixir"
  end

  test "index shows tags for tagged links" do
    get links_url
    assert_select "span.post-list__date", /ruby/
  end
end
