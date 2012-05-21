class AddImageContentTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :image_content_type, :string

    add_column :users, :image_name, :string

  end
end
