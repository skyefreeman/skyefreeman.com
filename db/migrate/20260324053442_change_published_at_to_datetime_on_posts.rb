class ChangePublishedAtToDatetimeOnPosts < ActiveRecord::Migration[8.1]
  def change
    change_column :posts, :published_at, :datetime
  end
end
