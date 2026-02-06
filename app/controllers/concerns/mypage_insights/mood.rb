# frozen_string_literal: true

module MypageInsights
  module Mood
    NEGATIVE_MOODS = %w[tired frustrated sad anxious angry].freeze

    private

    def build_mood_insight(mood_posts)
      return mood_insight_not_enough if mood_posts.size < 2

      mood_counts = tally_moods(mood_posts)
      mood_summary = build_mood_summary(mood_counts)
      scores = mood_scores(mood_posts)

      insight_by_priority(mood_counts, scores, mood_summary)
    end

    def insight_by_priority(mood_counts, scores, mood_summary)
      return mood_insight_negative_ratio(mood_summary) if negative_ratio(mood_counts) >= 0.6
      return mood_insight_low_average(mood_summary) if average(scores) <= 2.2

      insight_by_trend(scores, mood_summary)
    end

    def insight_by_trend(scores, mood_summary)
      first_avg, second_avg = split_averages(scores)
      return mood_insight_down(mood_summary) if trend_down?(first_avg, second_avg)
      return mood_insight_up(mood_summary) if trend_up?(first_avg, second_avg)

      mood_insight_stable(mood_summary)
    end

    def mood_insight_not_enough
      '今月は心の整理箱の記録がまだ少なめです。無理のないペースで書いてみましょう。'
    end

    def tally_moods(mood_posts)
      mood_posts.map(&:mood).tally
    end

    def build_mood_summary(mood_counts)
      top_mood = mood_counts.max_by { |_, count| count }&.first
      label = mood_label(top_mood)
      label ? "一番多い気分は「#{label}」です。" : nil
    end

    def mood_label(mood)
      return nil if mood.nil?

      Post::MOODS[mood.to_sym][:label]
    rescue StandardError
      nil
    end

    def mood_scores(mood_posts)
      mood_posts.map { |post| Post::MOODS[post.mood.to_sym][:score] }
    end

    def average(nums)
      return 0.0 if nums.empty?

      nums.sum / nums.size.to_f
    end

    def split_averages(scores)
      midpoint = scores.size / 2
      first = scores.take(midpoint)
      second = scores.drop(midpoint)

      [average(first), average(second)]
    end

    def negative_ratio(mood_counts)
      negative = mood_counts.slice(*NEGATIVE_MOODS).values.sum
      total = mood_counts.values.sum
      return 0.0 if total.zero?

      negative / total.to_f
    end

    def trend_down?(first_avg, second_avg)
      second_avg < first_avg - 0.4
    end

    def trend_up?(first_avg, second_avg)
      second_avg > first_avg + 0.4
    end

    def mood_insight_negative_ratio(mood_summary)
      "今月は疲れやモヤモヤが多かったようです。悩みや疲れが多い傾向があるようです。休める時間を意識してみてください。#{mood_summary}"
    end

    def mood_insight_low_average(mood_summary)
      "今月は疲れやモヤモヤが多かったようです。無理のないペースで過ごしましょう。#{mood_summary}"
    end

    def mood_insight_down(mood_summary)
      "最近は気分が下降気味のようです。今週は大変な日でしたね、お疲れ様でした。#{mood_summary}"
    end

    def mood_insight_up(mood_summary)
      "最近は気分が上向きのようです。この調子で小さな喜びを大切にしましょう。#{mood_summary}"
    end

    def mood_insight_stable(mood_summary)
      "気分は安定しています。今のペースを大切にしましょう。#{mood_summary}"
    end
  end
end
