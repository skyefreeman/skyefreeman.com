json.extract! game, :id, :title, :description, :download_url_linux, :download_url_macos, :download_url_windows, :created_at, :updated_at
json.url game_url(game, format: :json)
