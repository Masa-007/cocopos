class RemovePostIdFromFlowers < ActiveRecord::Migration[7.1]
  def change
    remove_column :flowers, :post_id, :bigint
  end
end
