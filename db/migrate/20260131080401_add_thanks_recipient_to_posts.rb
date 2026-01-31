class AddThanksRecipientToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :thanks_recipient, :integer
    add_column :posts, :thanks_recipient_other, :string
  end
end
