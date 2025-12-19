class CreateMilestones < ActiveRecord::Migration[7.1]
  def change
    create_table :milestones do |t|
      t.references :post, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end
  end
end

