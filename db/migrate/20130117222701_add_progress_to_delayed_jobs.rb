class AddProgressToDelayedJobs < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :progress, :integer
  end
end
