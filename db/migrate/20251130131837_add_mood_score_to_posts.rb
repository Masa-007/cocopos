class AddMoodScoreToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :mood_score, :integer
  end
end
