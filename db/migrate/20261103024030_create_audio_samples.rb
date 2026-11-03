class CreateAudioSamples < ActiveRecord::Migration[8.1]
  def change
    create_table :audio_samples do |t|
      t.text :description, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.decimal :duration_seconds, precision: 10, scale: 3, null: false

      t.timestamps
    end
  end
end
