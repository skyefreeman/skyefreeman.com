class AddSlugAndItchToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :url_slug, :string
    add_column :games, :download_url_itch, :string
  end
end
