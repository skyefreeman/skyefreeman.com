class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :title
      t.text :description
      t.string :download_url_linux
      t.string :download_url_macos
      t.string :download_url_windows

      t.timestamps
    end
  end
end
