class RemoveStateFromPosts < ActiveRecord::Migration[8.1]
  def change
    remove_column :posts, :state, :string
  end
end
