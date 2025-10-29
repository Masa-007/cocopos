class RenameBodyToContentInComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :body, :content
  end
end
