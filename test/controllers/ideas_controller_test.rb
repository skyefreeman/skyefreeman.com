require "test_helper"

class IdeasControllerTest < ActionDispatch::IntegrationTest
  # Public access to index and show

  test "index is accessible without authentication" do
    get ideas_path
    assert_response :success
  end

  test "index shows title as plain text when unauthenticated" do
    get ideas_path
    assert_select "span.post-list__title", text: ideas(:one).title
    assert_select "a.post-list__title", count: 0
  end

  test "index shows title as link when authenticated" do
    sign_in_as(users(:one))
    get ideas_path
    assert_select "a.post-list__title", text: ideas(:one).title
  end

  test "index shows output_url as link when present regardless of auth" do
    get ideas_path
    assert_select "a[href='#{ideas(:one).output_url}']"
  end

  test "show shows output_url as link when present" do
    sign_in_as(users(:one))
    get idea_path(ideas(:one))
    assert_select "a[href='#{ideas(:one).output_url}']"
  end

  test "index shows DONE label next to output_url" do
    get ideas_path
    assert_select "span.idea__done", text: "DONE"
  end

  test "show shows DONE label next to output_url" do
    sign_in_as(users(:one))
    get idea_path(ideas(:one))
    assert_select "span.idea__done", text: "DONE"
  end

  test "show omits DONE label when output_url is absent" do
    sign_in_as(users(:one))
    get idea_path(ideas(:two))
    assert_select "span.idea__done", count: 0
  end

  test "index omits output_url link when absent" do
    get ideas_path
    assert_select "li.post-list__item", text: /#{ideas(:two).title}/ do
      assert_select "a[href]", count: 0
    end
  end

  test "show redirects to login when unauthenticated" do
    get idea_path(ideas(:one))
    assert_redirected_to new_session_path
  end

  # Unauthenticated access to write actions redirects to login

  test "new redirects to login when unauthenticated" do
    get new_idea_path
    assert_redirected_to new_session_path
  end

  test "create redirects to login when unauthenticated" do
    post ideas_path, params: { idea: { title: "New Idea" } }
    assert_redirected_to new_session_path
  end

  test "edit redirects to login when unauthenticated" do
    get edit_idea_path(ideas(:one))
    assert_redirected_to new_session_path
  end

  test "update redirects to login when unauthenticated" do
    patch idea_path(ideas(:one)), params: { idea: { title: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "destroy redirects to login when unauthenticated" do
    delete idea_path(ideas(:one))
    assert_redirected_to new_session_path
  end

  # Authenticated write actions

  test "new returns a blank idea form when authenticated" do
    sign_in_as(users(:one))
    get new_idea_path
    assert_response :success
  end

  test "create saves a new idea and redirects when authenticated" do
    sign_in_as(users(:one))
    post ideas_path, params: { idea: { title: "New Idea" } }
    assert_redirected_to ideas_path
  end

  test "edit returns the idea form when authenticated" do
    sign_in_as(users(:one))
    get edit_idea_path(ideas(:one))
    assert_response :success
  end

  test "update saves changes and redirects when authenticated" do
    sign_in_as(users(:one))
    patch idea_path(ideas(:one)), params: { idea: { title: "Updated Title" } }
    assert_redirected_to ideas_path
  end

  test "create saves tags when tag_names param is provided" do
    sign_in_as(users(:one))
    post ideas_path, params: { idea: { title: "Tagged Idea", tag_names: "ruby, elixir" } }
    assert_equal 2, Idea.last.tags.count
  end

  test "update saves tags when tag_names param is provided" do
    sign_in_as(users(:one))
    patch idea_path(ideas(:one)), params: { idea: { tag_names: "elixir" } }
    assert_includes ideas(:one).reload.tags.map(&:name), "elixir"
  end

  test "index shows tags for tagged ideas" do
    get ideas_path
    assert_select "span.post-list__date", /rails/
  end

  test "destroy deletes the idea and redirects to index when authenticated" do
    sign_in_as(users(:one))
    delete idea_path(ideas(:one))
    assert_redirected_to ideas_path
  end

  test "create with invalid params re-renders new" do
    sign_in_as(users(:one))
    post ideas_path, params: { idea: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update with invalid params re-renders edit" do
    sign_in_as(users(:one))
    patch idea_path(ideas(:one)), params: { idea: { title: "" } }
    assert_response :unprocessable_entity
  end
end
