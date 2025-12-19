class AddProgressAndDeadlineToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :progress, :integer, default: 0, null: false
    add_column :posts, :deadline, :date
  end
end

