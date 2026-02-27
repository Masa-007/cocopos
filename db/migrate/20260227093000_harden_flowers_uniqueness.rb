# frozen_string_literal: true

class HardenFlowersUniqueness < ActiveRecord::Migration[7.1]
  UNIQUE_INDEX_NAME = 'index_flowers_on_user_and_flowerable_unique'

  def up
    remove_orphan_flower_rows
    remove_duplicate_flower_rows
    refresh_flower_counters

    change_column_null :flowers, :flowerable_type, false
    change_column_null :flowers, :flowerable_id, false

    add_index :flowers, %i[user_id flowerable_type flowerable_id], unique: true, name: UNIQUE_INDEX_NAME
  end

  def down
    remove_index :flowers, name: UNIQUE_INDEX_NAME

    change_column_null :flowers, :flowerable_type, true
    change_column_null :flowers, :flowerable_id, true
  end

  private

  def remove_orphan_flower_rows
    execute <<~SQL
      DELETE FROM flowers
      WHERE flowerable_type IS NULL
         OR flowerable_id IS NULL;
    SQL
  end

  def remove_duplicate_flower_rows
    execute <<~SQL
      DELETE FROM flowers
      WHERE id IN (
        SELECT id
        FROM (
          SELECT id,
                 ROW_NUMBER() OVER (
                   PARTITION BY user_id, flowerable_type, flowerable_id
                   ORDER BY id
                 ) AS row_num
          FROM flowers
        ) duplicated
        WHERE duplicated.row_num > 1
      );
    SQL
  end

  def refresh_flower_counters
    execute <<~SQL
      UPDATE posts
      SET flowers_count = COALESCE(counts.count, 0)
      FROM (
        SELECT flowerable_id, COUNT(*) AS count
        FROM flowers
        WHERE flowerable_type = 'Post'
        GROUP BY flowerable_id
      ) counts
      WHERE posts.id = counts.flowerable_id;
    SQL

    execute <<~SQL
      UPDATE posts
      SET flowers_count = 0
      WHERE id NOT IN (
        SELECT DISTINCT flowerable_id
        FROM flowers
        WHERE flowerable_type = 'Post'
      );
    SQL

    execute <<~SQL
      UPDATE comments
      SET flowers_count = COALESCE(counts.count, 0)
      FROM (
        SELECT flowerable_id, COUNT(*) AS count
        FROM flowers
        WHERE flowerable_type = 'Comment'
        GROUP BY flowerable_id
      ) counts
      WHERE comments.id = counts.flowerable_id;
    SQL

    execute <<~SQL
      UPDATE comments
      SET flowers_count = 0
      WHERE id NOT IN (
        SELECT DISTINCT flowerable_id
        FROM flowers
        WHERE flowerable_type = 'Comment'
      );
    SQL
  end
end
