class RemoveFsPasswordFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :fs_password
  end

  def down
    add_column :users, :fs_password, :string
  end
end
