class AddLastAiUsedAtToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_ai_used_at, :datetime
  end
end
