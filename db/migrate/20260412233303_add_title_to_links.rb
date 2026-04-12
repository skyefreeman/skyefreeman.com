class AddTitleToLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :links, :title, :string
  end
end
