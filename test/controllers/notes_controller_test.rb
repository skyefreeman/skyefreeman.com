require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  # Public access

  test "index is accessible without authentication" do
    get notes_path
    assert_response :success
  end

  test "show is accessible without authentication" do
    get note_path(notes(:one))
    assert_response :success
  end

  # Unauthenticated write access redirects to login

  test "new redirects to login when unauthenticated" do
    get new_note_path
    assert_redirected_to new_session_path
  end

  test "create redirects to login when unauthenticated" do
    post notes_path, params: { note: { title: "New Note", body: "Hello" } }
    assert_redirected_to new_session_path
  end

  test "edit redirects to login when unauthenticated" do
    get edit_note_path(notes(:one))
    assert_redirected_to new_session_path
  end

  test "update redirects to login when unauthenticated" do
    patch note_path(notes(:one)), params: { note: { title: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "destroy redirects to login when unauthenticated" do
    delete note_path(notes(:one))
    assert_redirected_to new_session_path
  end

  # Authenticated access succeeds

  test "index lists notes" do
    get notes_path
    assert_select "a.post-list__title", text: notes(:one).title
  end

  test "new returns a blank note form when authenticated" do
    sign_in_as(users(:one))
    get new_note_path
    assert_response :success
  end

  test "create saves a new note and redirects when authenticated" do
    sign_in_as(users(:one))
    post notes_path, params: { note: { title: "New Note", body: "Hello" } }
    assert_redirected_to note_path(Note.last)
  end

  test "create saves tags when tag_names param is provided" do
    sign_in_as(users(:one))
    post notes_path, params: { note: { title: "Tagged Note", tag_names: "ruby, elixir" } }
    assert_equal 2, Note.last.tags.count
  end

  test "update saves tags when tag_names param is provided" do
    sign_in_as(users(:one))
    patch note_path(notes(:one)), params: { note: { tag_names: "elixir" } }
    assert_includes notes(:one).reload.tags.map(&:name), "elixir"
  end

  test "index shows tags for tagged notes" do
    get notes_path
    assert_select "span.post-list__date", /ruby/
  end

  test "edit returns the note form when authenticated" do
    sign_in_as(users(:one))
    get edit_note_path(notes(:one))
    assert_response :success
  end

  test "update saves changes and redirects when authenticated" do
    sign_in_as(users(:one))
    patch note_path(notes(:one)), params: { note: { title: "Updated Title" } }
    assert_redirected_to note_path(notes(:one))
  end

  test "destroy deletes the note and redirects to index when authenticated" do
    sign_in_as(users(:one))
    delete note_path(notes(:one))
    assert_redirected_to notes_path
  end

  test "create with invalid params re-renders new" do
    sign_in_as(users(:one))
    post notes_path, params: { note: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "update with invalid params re-renders edit" do
    sign_in_as(users(:one))
    patch note_path(notes(:one)), params: { note: { title: "" } }
    assert_response :unprocessable_entity
  end
end
