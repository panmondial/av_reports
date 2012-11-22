class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :state_province, :string
    add_column :users, :zip_postalcode, :string
    add_column :users, :lead_source, :string
  end
end
