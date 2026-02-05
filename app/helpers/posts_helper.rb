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

  def render_markdown(text)
    return '' if text.blank?

    escaped_text = ERB::Util.html_escape(text)
    lines = escaped_text.split("\n")
    html = []
    paragraph_lines = []
    list_items = []
    in_code_block = false
    code_lines = []

    flush_paragraph = lambda do
      return if paragraph_lines.empty?

      content = paragraph_lines.join("\n")
      html << "<p>#{format_inline_markdown(content)}</p>"
      paragraph_lines.clear
    end

    flush_list = lambda do
      return if list_items.empty?

      items = list_items.map { |item| "<li>#{item}</li>" }.join
      html << "<ul>#{items}</ul>"
      list_items.clear
    end

    lines.each do |line|
      if line.strip.start_with?('```')
        flush_paragraph.call
        flush_list.call

        if in_code_block
          html << "<pre><code>#{code_lines.join("\n")}</code></pre>"
          code_lines.clear
          in_code_block = false
        else
          in_code_block = true
        end
        next
      end

      if in_code_block
        code_lines << line
        next
      end

      if (match = line.match(/^(\#{1,6})\s+(.*)$/))
        flush_paragraph.call
        flush_list.call
        level = match[1].length
        html << "<h#{level}>#{format_inline_markdown(match[2])}</h#{level}>"
        next
      end

      if line.match?(/^\s*[-*]\s+/)
        flush_paragraph.call
        content = line.sub(/^\s*[-*]\s+/, '')
        list_items << format_inline_markdown(content)
        next
      end

      if line.strip.empty?
        flush_paragraph.call
        flush_list.call
        next
      end

      flush_list.call if list_items.any?
      paragraph_lines << line
    end

    html << "<pre><code>#{code_lines.join("\n")}</code></pre>" if in_code_block

    flush_paragraph.call
    flush_list.call

    html.join("\n").html_safe
  end

  def markdown_plain_text(text)
    return '' if text.blank?

    escaped = ERB::Util.html_escape(text)

    escaped = escaped.gsub(/^\s*```.*$/, '')
    escaped = escaped.gsub(/^\s*\#{1,6}\s+/, '')
    escaped = escaped.gsub(/^\s*[-*]\s+/, '')
    escaped = escaped.gsub(/\[([^\]]+)\]\(([^)]+)\)/, '\1')
    escaped = escaped.gsub(/\*\*(.+?)\*\*/, '\1')
    escaped = escaped.gsub(/`([^`]+)`/, '\1')
    escaped.gsub(/\*(.+?)\*/, '\1')
  end

  private

  def format_inline_markdown(text)
    text
      .gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      .gsub(/`([^`]+)`/, '<code>\1</code>')
      .gsub(/\*(.+?)\*/, '<em>\1</em>')
      .gsub(/\[([^\]]+)\]\(([^)]+)\)/, '<a href="\2" target="_blank" rel="noopener noreferrer">\1</a>')
  end
end
