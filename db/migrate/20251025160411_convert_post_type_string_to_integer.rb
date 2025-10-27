# frozen_string_literal: true

class ConvertPostTypeStringToInteger < ActiveRecord::Migration[7.1]
  def up
    # 1. 一時カラムを追加
    add_column :posts, :post_type_tmp, :integer, default: 0

    # 2. 文字列から整数へ変換
    Post.reset_column_information
    Post.find_each do |post|
      case post.post_type
      when 'future'   then post.update_column(:post_type_tmp, 0)
      when 'organize' then post.update_column(:post_type_tmp, 1)
      when 'thanks'   then post.update_column(:post_type_tmp, 2)
      else
        post.update_column(:post_type_tmp, 0) # fallback
      end
    end

    # 3. 古いカラム削除 → 新しいカラムをリネーム
    remove_column :posts, :post_type
    rename_column :posts, :post_type_tmp, :post_type
  end

  def down
    add_column :posts, :post_type_tmp, :string

    Post.reset_column_information
    Post.find_each do |post|
      case post.post_type
      when 0 then post.update_column(:post_type_tmp, 'future')
      when 1 then post.update_column(:post_type_tmp, 'organize')
      when 2 then post.update_column(:post_type_tmp, 'thanks')
      end
    end

    remove_column :posts, :post_type
    rename_column :posts, :post_type_tmp, :post_type
  end
end
