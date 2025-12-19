class RenameDoneToCompletedInMilestones < ActiveRecord::Migration[7.1]
  def change
    rename_column :milestones, :done, :completed
  end
end

