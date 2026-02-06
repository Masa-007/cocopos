# frozen_string_literal: true

module MypageInsights
  module Future
    private

    def build_future_insight(future_posts)
      return future_insight_empty if future_posts.blank?
      return future_insight_deadline if urgent_low_progress?(future_posts)

      avg_progress = average_progress(future_posts)
      return '進捗は順調です。達成まであと少しですね。' if avg_progress >= 70
      return 'まだ余白が多いようです。できることから整理してみましょう。' if avg_progress <= 30

      '着実に進んでいます。小さな達成を積み重ねましょう。'
    end

    def urgent_low_progress?(future_posts)
      future_posts.any? { |post| urgent_low_progress_post?(post) }
    end

    def urgent_low_progress_post?(post)
      return false if post.deadline.blank?

      post.deadline <= Date.current + 7.days && post.progress.to_i < 50
    end

    def average_progress(future_posts)
      progresses = future_posts.map { |post| post.progress.to_i }
      average(progresses)
    end

    def average(nums)
      return 0.0 if nums.empty?

      nums.sum / nums.size.to_f
    end

    def future_insight_empty
      '今月は未来宣言箱の投稿がありません。小さな目標から書いてみましょう。'
    end

    def future_insight_deadline
      '期限が近いTODOがあるようです。無理のない範囲で一歩進めてみましょう。'
    end
  end
end
