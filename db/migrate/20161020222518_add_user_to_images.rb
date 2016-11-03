class AddUserToImages < ActiveRecord::Migration[5.0]
  def up
    user = User.find_or_create_by(email: 'admin@email.com') do |new_user|
      new_user.password = 'leeroyjenkins'
    end

    add_reference :images, :user, foreign_key: true

    execute "UPDATE images SET user_id=#{user.id} WHERE user_id IS NULL"

    change_column_null :images, :user_id, false
  end

  def down
    remove_reference :images, :user, foreign_key: true
  end
end
