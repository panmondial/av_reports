class RemoveFsPasswordHashFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :fs_password_hash
  end

  def down
    add_column :users, :fs_password_hash, :string
  end
end
