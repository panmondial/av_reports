class AddRegistrationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registration_token, :string
    add_column :users, :registration_sent_at, :datetime
  end
end
