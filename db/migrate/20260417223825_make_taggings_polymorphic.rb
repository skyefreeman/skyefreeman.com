class MakeTaggingsPolymorphic < ActiveRecord::Migration[8.1]
  def up
    add_column :taggings, :taggable_type, :string
    add_column :taggings, :taggable_id, :bigint

    execute "UPDATE taggings SET taggable_type = 'Post', taggable_id = post_id"

    change_column_null :taggings, :taggable_type, false
    change_column_null :taggings, :taggable_id, false

    remove_foreign_key :taggings, :posts
    remove_index :taggings, :post_id
    remove_column :taggings, :post_id

    add_index :taggings, [:taggable_type, :taggable_id]
    add_index :taggings, [:taggable_type, :taggable_id, :tag_id], unique: true, name: "index_taggings_on_taggable_and_tag"
  end

  def down
    add_column :taggings, :post_id, :bigint

    execute "UPDATE taggings SET post_id = taggable_id WHERE taggable_type = 'Post'"

    change_column_null :taggings, :post_id, false

    remove_index :taggings, name: "index_taggings_on_taggable_and_tag"
    remove_index :taggings, [:taggable_type, :taggable_id]
    remove_column :taggings, :taggable_id
    remove_column :taggings, :taggable_type

    add_index :taggings, :post_id
    add_foreign_key :taggings, :posts
  end
end
