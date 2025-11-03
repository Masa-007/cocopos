class AddFlowerableToFlowers < ActiveRecord::Migration[7.0]
  def change
    add_reference :flowers, :flowerable, polymorphic: true, null: true
  end
end
