class RemoveFsPasswordSaltFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :fs_password_salt
  end

  def down
    add_column :users, :fs_password_salt, :string
  end
end
