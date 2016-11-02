class AddUserToImages < ActiveRecord::Migration[5.0]
  def change
    user = User.create!(email: 'admin@email.com', password: 'leeroyjenkins')

    add_reference :images, :user, foreign_key: true, null: false, default: user.id

    execute "UPDATE images SET user_id=#{user.id}"
  end
end
