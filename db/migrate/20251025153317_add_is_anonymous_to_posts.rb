class AddIsAnonymousToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :is_anonymous, :boolean
  end
end
