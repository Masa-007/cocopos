# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :post_type, null: false, default: 0
      t.boolean :comment_allowed, default: true
      t.boolean :is_anonymous, default: true

      t.timestamps
    end

    add_index :posts, :post_type
    add_index :posts, :created_at
  end
end
