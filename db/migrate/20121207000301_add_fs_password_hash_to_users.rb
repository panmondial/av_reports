class AddFsPasswordHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fs_password_hash, :string
  end
end
