require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:one)
  end

  test "new and edit forms provide upload feedback and native fallback" do
    sign_in_as(users(:one))
    [ new_game_path, edit_game_path(@game) ].each do |path|
      get path
      assert_select "form#game-form[data-controller=game-upload][data-turbo=false][enctype='multipart/form-data']" do
        assert_select "progress[data-game-upload-target=progress]"
        assert_select "[role=status][data-game-upload-target=status]"
        assert_select "[role=alert][data-game-upload-target=error]"
      end
      assert_select "input[type=submit][form=game-form]"
    end
  end

  test "JSON create uploads a package and returns the saved game location" do
    sign_in_as(users(:one))
    assert_difference "Game.count" do
      post games_path, params: { game: { title: "Uploaded", linux_package: fixture_file_upload("game.zip", "application/zip") } }, headers: { "Accept" => "application/json" }
    end
    assert_response :success
    assert_equal game_path(Game.last), response.parsed_body["location"]
    assert Game.last.linux_package.attached?
  end

  test "JSON update returns the saved location" do
    sign_in_as(users(:one))
    patch game_path(@game), params: { game: { title: "Updated upload" } }, headers: { "Accept" => "application/json" }
    assert_response :success
    assert_equal game_path(@game), response.parsed_body["location"]
    assert_equal "Updated upload", @game.reload.title
  end

  test "JSON saves return validation errors without changing records" do
    sign_in_as(users(:one))
    assert_no_difference "Game.count" do
      post games_path, params: { game: { title: "" } }, headers: { "Accept" => "application/json" }
    end
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Title can't be blank"

    assert_no_changes -> { @game.reload.title } do
      patch game_path(@game), params: { game: { title: "" } }, headers: { "Accept" => "application/json" }
    end
    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Title can't be blank"
  end

  # Unauthenticated access

  test "index is accessible without authentication" do
    get games_url
    assert_response :success
  end

  test "show is accessible without authentication" do
    get game_url(@game)
    assert_response :success
  end

  test "show is accessible by slug without authentication" do
    get game_by_slug_path(@game.url_slug)
    assert_response :success
  end

  test "show by unknown slug returns 404" do
    get game_by_slug_path("nonexistent-slug")
    assert_response :not_found
  end

  test "new redirects when unauthenticated" do
    get new_game_url
    assert_redirected_to new_session_path
  end

  test "create redirects when unauthenticated" do
    post games_url, params: { game: { title: "Test Game" } }
    assert_redirected_to new_session_path
  end

  test "edit redirects when unauthenticated" do
    get edit_game_url(@game)
    assert_redirected_to new_session_path
  end

  test "update redirects when unauthenticated" do
    patch game_url(@game), params: { game: { title: "Updated" } }
    assert_redirected_to new_session_path
  end

  test "destroy redirects when unauthenticated" do
    delete game_url(@game)
    assert_redirected_to new_session_path
  end

  # Authenticated access

  test "index lists games" do
    sign_in_as(users(:one))
    get games_url
    assert_select "h2.game-list__title", text: @game.title
  end

  test "show displays game title" do
    sign_in_as(users(:one))
    get game_url(@game)
    assert_select "h1.page-content__title", text: @game.title
  end

  test "should get new" do
    sign_in_as(users(:one))
    get new_game_url
    assert_response :success
  end

  test "should create game" do
    sign_in_as(users(:one))
    assert_difference("Game.count") do
      post games_url, params: { game: { title: "New Game", description: "A new game." } }
    end
    assert_redirected_to game_url(Game.last)
  end

  test "create with invalid params re-renders new" do
    sign_in_as(users(:one))
    post games_url, params: { game: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    sign_in_as(users(:one))
    get edit_game_url(@game)
    assert_response :success
  end

  test "should update game" do
    sign_in_as(users(:one))
    patch game_url(@game), params: { game: { title: "Updated Title" } }
    assert_redirected_to game_url(@game)
    assert_equal "Updated Title", @game.reload.title
  end

  test "should destroy game" do
    sign_in_as(users(:one))
    assert_difference("Game.count", -1) do
      delete game_url(@game)
    end
    assert_redirected_to games_url
  end

  test "create attaches linux package" do
    sign_in_as(users(:one))
    file = fixture_file_upload("game.zip", "application/zip")
    post games_url, params: { game: { title: "New Game", linux_package: file } }
    assert Game.last.linux_package.attached?
  end

  test "update attaches macos package" do
    sign_in_as(users(:one))
    file = fixture_file_upload("game.zip", "application/zip")
    patch game_url(@game), params: { game: { macos_package: file } }
    assert @game.reload.macos_package.attached?
  end
end
