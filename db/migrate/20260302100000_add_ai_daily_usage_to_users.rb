# frozen_string_literal: true

class AddAiDailyUsageToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :ai_used_on, :date
    add_column :users, :ai_used_count, :integer, null: false, default: 0
  end
end
