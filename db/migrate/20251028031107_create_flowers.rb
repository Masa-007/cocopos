# frozen_string_literal: true

# db/migrate/xxxx_create_flowers.rb
class CreateFlowers < ActiveRecord::Migration[7.0]
  def change
    create_table :flowers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.timestamps
    end

    add_index :flowers, %i[user_id post_id], unique: true
  end
end
