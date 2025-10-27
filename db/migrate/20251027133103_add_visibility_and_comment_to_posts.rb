# frozen_string_literal: true

class AddVisibilityAndCommentToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :is_public, :boolean, default: true, null: false
    add_column :posts, :comment_allowed, :boolean, default: true, null: false
  end
end
