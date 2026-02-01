# frozen_string_literal: true

module MypageInsights
  private

  def build_mood_insight(mood_posts)
    return '今月は心の整理箱の記録がまだ少なめです。無理のないペースで書いてみましょう。' if mood_posts.size < 2

    mood_counts = mood_posts.map(&:mood).tally
    top_mood = mood_counts.max_by { |_, count| count }&.first
    top_label = top_mood ? Post::MOODS[top_mood.to_sym][:label] : nil

    scores = mood_posts.map { |post| Post::MOODS[post.mood.to_sym][:score] }
    average = scores.sum / scores.size.to_f
    midpoint = scores.size / 2
    first_average = scores.take(midpoint).sum / midpoint.to_f
    second_average = scores.drop(midpoint).sum / (scores.size - midpoint).to_f

    negative_moods = %w[tired frustrated sad anxious angry]
    negative_ratio = mood_counts.slice(*negative_moods).values.sum / mood_counts.values.sum.to_f
    mood_summary = top_label ? "一番多い気分は「#{top_label}」です。" : nil

    if second_average < first_average - 0.4
      "最近は気分が下降気味のようです。今週は大変な日でしたね、お疲れ様でした。#{mood_summary}"
    elsif second_average > first_average + 0.4
      "最近は気分が上向きのようです。この調子で小さな喜びを大切にしましょう。#{mood_summary}"
    elsif negative_ratio >= 0.6
      "悩みや疲れが多い傾向があるようです。休める時間を意識してみてください。#{mood_summary}"
    elsif average <= 2.2
      "今月は疲れやモヤモヤが多かったようです。無理のないペースで過ごしましょう。#{mood_summary}"
    else
      "気分は安定しています。今のペースを大切にしましょう。#{mood_summary}"
    end
  end

  def build_future_insight(future_posts)
    return '今月は未来宣言箱の投稿がありません。小さな目標から書いてみましょう。' if future_posts.blank?

    urgent_posts = future_posts.select do |post|
      post.deadline.present? && post.deadline <= Date.current + 7.days && post.progress.to_i < 50
    end
    return '期限が近いTODOがあるようです。無理のない範囲で一歩進めてみましょう。' if urgent_posts.any?

    average_progress = future_posts.map { |post| post.progress.to_i }.sum / future_posts.size.to_f

    if average_progress >= 70
      '進捗は順調です。達成まであと少しですね。'
    elsif average_progress <= 30
      'まだ余白が多いようです。できることから整理してみましょう。'
    else
      '着実に進んでいます。小さな達成を積み重ねましょう。'
    end
  end

  def build_thanks_recipients_summary(thanks_posts)
    tags = thanks_posts.map(&:thanks_recipient_tag).compact
    tags.tally.map { |label, count| { label: label.delete_prefix('#'), count: count } }
        .sort_by { |item| [-item[:count], item[:label]] }
  end

  def build_thanks_insight(summary)
    return '今月は感謝箱の記録がまだ少なめです。身近なありがとうを思い出してみましょう。' if summary.blank?

    top = summary.first
    "最近は#{top[:label]}への感謝が多いようです。温かな気持ちを大切にしましょう。"
  end
end
