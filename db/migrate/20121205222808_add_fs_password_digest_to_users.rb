class AddFsPasswordDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fs_password_digest, :string
  end
end
