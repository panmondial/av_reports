class AddLeadSourceOtherToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lead_source_other, :string
  end
end
