class RenameDoneToCompletedInMilestonesV2 < ActiveRecord::Migration[7.1]
  def change
    return unless column_exists?(:milestones, :done)
    return if column_exists?(:milestones, :completed)

    rename_column :milestones, :done, :completed
  end
end
