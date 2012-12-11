class AddFsUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fs_username, :string
  end
end
