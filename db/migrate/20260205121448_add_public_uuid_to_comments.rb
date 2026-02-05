# frozen_string_literal: true
class AddPublicUuidToComments < ActiveRecord::Migration[7.1]
  def up
    add_column :comments, :public_uuid, :string
    add_index :comments, :public_uuid, unique: true

    Comment.reset_column_information
    Comment.find_each do |comment|
      comment.update_columns(public_uuid: SecureRandom.uuid) # rubocop:disable Rails/SkipsModelValidations
    end

    change_column_null :comments, :public_uuid, false
  end

  def down
    remove_index :comments, :public_uuid
    remove_column :comments, :public_uuid
  end
end
