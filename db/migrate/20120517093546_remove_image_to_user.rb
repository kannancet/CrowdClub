class RemoveImageToUser < ActiveRecord::Migration
  def up
    remove_column :users, :image
      end

  def down
    add_column :users, :image, :text
  end
end
