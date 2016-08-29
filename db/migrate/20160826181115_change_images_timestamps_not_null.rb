class ChangeImagesTimestampsNotNull < ActiveRecord::Migration[5.0]
  def change
    change_column_null(:images, :created_at, false, Time.zone.now)
    change_column_null(:images, :updated_at, false, Time.zone.now)
  end
end
