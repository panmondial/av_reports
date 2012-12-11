class AddFsPasswordSaltToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fs_password_salt, :string
  end
end
