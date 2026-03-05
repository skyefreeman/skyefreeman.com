class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :author
      t.string :state
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
