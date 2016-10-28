class AddLikesTableAndAddLikeToImageAndUser < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.references :image, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
    end

    add_column :images, :likes_count, :integer, null: false, default: 0
  end
end
