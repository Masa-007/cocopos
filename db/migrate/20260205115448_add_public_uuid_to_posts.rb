# frozen_string_literal: true

class AddPublicUuidToPosts < ActiveRecord::Migration[7.1]
  def up
    add_column :posts, :public_uuid, :string

    # 既存データにUUIDを埋める（index/NOT NULL 前に）
    Post.reset_column_information
    Post.find_each do |post|
      post.update_columns(public_uuid: SecureRandom.uuid) # rubocop:disable Rails/SkipsModelValidations
    end

    change_column_null :posts, :public_uuid, false
    add_index :posts, :public_uuid, unique: true
  end

  def down
    remove_index :posts, :public_uuid if index_exists?(:posts, :public_uuid)
    remove_column :posts, :public_uuid if column_exists?(:posts, :public_uuid)
  end
end
