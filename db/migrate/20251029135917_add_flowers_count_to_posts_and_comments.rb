class AddFlowersCountToPostsAndComments < ActiveRecord::Migration[7.0]
  def change

    unless column_exists?(:posts, :flowers_count)
      add_column :posts, :flowers_count, :integer, default: 0, null: false
    end

    unless column_exists?(:comments, :flowers_count)
      add_column :comments, :flowers_count, :integer, default: 0, null: false
    end
  end
end
