class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.text :comment
      t.text :image
      t.integer :category_id
      t.integer :user_id
      t.integer :location_id

      t.timestamps
    end
  end
end
