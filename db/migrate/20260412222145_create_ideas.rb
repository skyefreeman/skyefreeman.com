class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.text :title
      t.string :output_url

      t.timestamps
    end
  end
end
