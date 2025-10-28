class Flower < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  after_destroy_commit :ensure_non_negative_count

  private

  def ensure_non_negative_count
    # 念のため負数を防ぐ
    post.update_column(:flowers_count, 0) if post.flowers_count.negative?
  end
end
