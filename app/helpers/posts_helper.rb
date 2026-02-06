# frozen_string_literal: true

module PostsHelper
  def selected_filter?(current, value)
    current = current.presence
    value = value.presence

    if value.blank?
      current.blank?
    elsif value == 'all'
      current.blank? || current == 'all'
    else
      current == value
    end
  end

  def sub_filter_options(filter)
    case filter
    when 'future'
      [
        { value: '', text: '詳細フィルターなし' },
        { value: 'future_achieved', text: '達成済のみ' },
        { value: 'future_unachieved', text: '未達のみ' }
      ]
    when 'organize'
      options = Post::MOODS.map do |key, data|
        label = data[:label].to_s
        sanitized_label = label.match?(/^_.*_fields$/) ? '' : label

        {
          value: key.to_s,
          text: sanitized_label.presence || key.to_s.humanize
        }
      end
      [{ value: '', text: '詳細フィルターなし' }] + options
    when 'thanks'
      options = Post::THANKS_RECIPIENTS.map do |key, label|
        { value: key.to_s, text: label }
      end
      [{ value: '', text: '詳細フィルターなし' }] + options
    else
      []
    end
  end

  def show_post_actions?(post, from:)
    return true if from == 'mypage'

    post.is_public?
  end

  def show_comment_button?(post)
    post.comment_allowed?
  end

  def show_private_badge?(post)
    user_signed_in? && post.user == current_user && !post.is_public?
  end

  def comment_status_badge(post)
    if post.comment_allowed?
      content_tag(
        :span,
        '💬 意見募集中',
        class: 'px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full font-bold'
      )
    else
      content_tag(
        :span,
        '💭 コメント不要',
        class: 'px-2 py-1 bg-gray-200 text-xs rounded-full'
      )
    end
  end
end
