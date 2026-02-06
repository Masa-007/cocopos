# frozen_string_literal: true

module MypageInsights
  module Thanks
    private

    def build_thanks_recipients_summary(thanks_posts)
      tags = thanks_posts.map(&:thanks_recipient_tag).compact
      tags.tally
          .map { |label, count| { label: label.delete_prefix('#'), count: } }
          .sort_by { |item| [-item[:count], item[:label]] }
    end

    def build_thanks_insight(summary)
      return '今月は感謝箱の記録がまだ少なめです。身近なありがとうを思い出してみましょう。' if summary.blank?

      top = summary.first
      "最近は#{top[:label]}への感謝が多いようです。温かな気持ちを大切にしましょう。"
    end
  end
end
