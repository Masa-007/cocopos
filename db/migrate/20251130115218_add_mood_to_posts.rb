class AddMoodToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :mood, :string
  end
end
