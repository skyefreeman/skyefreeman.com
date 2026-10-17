class AddBodyToLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :links, :body, :text
  end
end
