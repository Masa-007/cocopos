# frozen_string_literal: true

module MypageInsights
  module Thanks
    private

    def build_thanks_recipients_summary(thanks_posts)
      tags = thanks_posts.map(&:thanks_recipient_tag).compact
      tags.tally
          .map { |label, count| { label: label.delete_prefix('#'), count: count } }
          .sort_by { |item| [-item[:count], item[:label]] }
    end

    def build_thanks_insight(summary)
      return not_enough_message if summary.blank?

      top   = summary.first
      label = top[:label]
      count = top[:count]
      total = summary.sum { |item| item[:count] }

      message = select_pattern(label, count, total)
      "#{message} 温かな気持ちを大切にしましょう。"
    end

    def not_enough_message
      '今月は感謝箱の記録がまだ少なめです。身近なありがとうを思い出してみましょう。'
    end

    def select_pattern(label, count, total)
      ratio = total.positive? ? count.to_f / total : 0

      patterns =
        if count == 1
          single_patterns(label)
        elsif ratio >= 0.5
          dominant_patterns(label)
        else
          normal_patterns(label)
        end

      patterns.sample
    end

    def single_patterns(label)
      [
        "今月は#{label}への最初の「ありがとう」が記録されています。",
        "#{label}への感謝が一つ、丁寧に綴られています。",
        "小さな一歩として、#{label}への想いが残されています。"
      ]
    end

    def dominant_patterns(label)
      [
        "今月は#{label}への感謝が中心になっていますね。",
        "#{label}への想いが、今月のテーマのようです。",
        "あなたの記録から、#{label}への強い感謝が感じられます。"
      ]
    end

    def normal_patterns(label)
      [
        "最近は#{label}への感謝が多いようです。",
        "#{label}への「ありがとう」が今月は印象的です。",
        "あなたの記録から、#{label}への温かな気持ちが伝わってきます。"
      ]
    end
  end
end
