# frozen_string_literal: true

module MarkdownHelper
  def render_markdown(text)
    return "" if text.blank?

    html = markdown_to_html(text.to_s)
    sanitize(
      html,
      tags: %w[p br strong em del a ul ol li blockquote code pre h1 h2 h3 h4 h5 h6 hr],
      attributes: %w[href title rel target]
    )
  end

  def markdown_plain_text(text)
    strip_tags(render_markdown(text))
  end

  private

  def markdown_to_html(text)
    escaped = ERB::Util.html_escape(text)
    normalized = escaped.gsub("\r\n", "\n")
    lines = normalized.split("\n", -1)
    blocks = []
    paragraph = []
    list_type = nil
    list_items = []
    code_block = []
    in_code_block = false

    flush_paragraph = lambda do
      next if paragraph.empty?

      blocks << "<p>#{inline_markdown(paragraph.join('<br>'))}</p>"
      paragraph.clear
    end

    flush_list = lambda do
      next if list_items.empty?

      tag = list_type == :ol ? "ol" : "ul"
      items_html = list_items.map { |item| "<li>#{inline_markdown(item)}</li>" }.join
      blocks << "<#{tag}>#{items_html}</#{tag}>"
      list_items.clear
      list_type = nil
    end

    lines.each do |line|
      if line.strip.start_with?("```")
        if in_code_block
          blocks << "<pre><code>#{code_block.join("\n")}</code></pre>"
          code_block.clear
          in_code_block = false
        else
          flush_paragraph.call
          flush_list.call
          in_code_block = true
        end
        next
      end

      if in_code_block
        code_block << line
        next
      end

      if line.strip.empty?
        flush_paragraph.call
        flush_list.call
        next
      end

      if (heading = line.match(/\A(#+)\s+(.+)\z/))
        flush_paragraph.call
        flush_list.call
        level = [heading[1].length, 6].min
        blocks << "<h#{level}>#{inline_markdown(heading[2])}</h#{level}>"
        next
      end

      if line.match?(/\A---+\s*\z/)
        flush_paragraph.call
        flush_list.call
        blocks << "<hr>"
        next
      end

      if (blockquote = line.match(/\A>\s+(.+)\z/))
        flush_paragraph.call
        flush_list.call
        blocks << "<blockquote><p>#{inline_markdown(blockquote[1])}</p></blockquote>"
        next
      end

      if (list_item = line.match(/\A\s*[-*]\s+(.+)\z/))
        flush_paragraph.call
        if list_type && list_type != :ul
          flush_list.call
        end
        list_type ||= :ul
        list_items << list_item[1]
        next
      end

      if (list_item = line.match(/\A\s*\d+\.\s+(.+)\z/))
        flush_paragraph.call
        if list_type && list_type != :ol
          flush_list.call
        end
        list_type ||= :ol
        list_items << list_item[1]
        next
      end

      paragraph << line
    end

    if in_code_block
      blocks << "<pre><code>#{code_block.join("\n")}</code></pre>"
    end

    flush_paragraph.call
    flush_list.call

    blocks.join
  end

  def inline_markdown(text)
    segments = text.split(/(`[^`]+`)/)
    segments.map! do |segment|
      if segment.start_with?("`") && segment.end_with?("`")
        "<code>#{segment[1..-2]}</code>"
      else
        segment = segment.gsub(/\*\*(.+?)\*\*/, "<strong>\\1</strong>")
        segment = segment.gsub(/\*(.+?)\*/, "<em>\\1</em>")
        segment.gsub(/\[(.+?)\]\((https?:\/\/[^\s)]+)\)/, '<a href="\\2" target="_blank" rel="noopener">\\1</a>')
      end
    end
    segments.join
  end
end
