# frozen_string_literal: true

class DeduplicateUsersNameCaseSensitive < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      WITH ranked AS (
        SELECT id,
               name,
               ROW_NUMBER() OVER (PARTITION BY name ORDER BY id) AS rn
        FROM users
        WHERE name IS NOT NULL AND name <> ''
      )
      UPDATE users u
      SET name = u.name || '_' || ranked.rn
      FROM ranked
      WHERE u.id = ranked.id
        AND ranked.rn > 1;
    SQL
  end

  def down
  end
end
