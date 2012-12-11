class AddFsPassword2ToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fs_password, :string
  end
end
