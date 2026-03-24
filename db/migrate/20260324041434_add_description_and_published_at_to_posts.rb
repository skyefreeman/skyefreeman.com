class AddDescriptionAndPublishedAtToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :description, :text
    add_column :posts, :published_at, :date
  end
end
