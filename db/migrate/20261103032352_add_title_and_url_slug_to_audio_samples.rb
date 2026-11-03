class AddTitleAndUrlSlugToAudioSamples < ActiveRecord::Migration[8.1]
  def up
    add_column :audio_samples, :title, :string
    add_column :audio_samples, :url_slug, :string
    add_index :audio_samples, :url_slug, unique: true

    execute <<~SQL.squish
      UPDATE audio_samples
      SET title = LEFT(description, 255)
      WHERE title IS NULL
    SQL

    change_column_null :audio_samples, :title, false
  end

  def down
    remove_index :audio_samples, :url_slug
    remove_column :audio_samples, :url_slug
    remove_column :audio_samples, :title
  end
end
