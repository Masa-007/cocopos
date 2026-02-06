# frozen_string_literal: true

ng_words_path = Rails.root.join('config/ng_words.txt')

NG_WORDS =
  if ng_words_path.exist?
    ng_words_path.read.split(/\s+/).compact_blank.uniq.freeze
  else
    Rails.logger.warn("[NG_WORDS] not found: #{ng_words_path}")
    [].freeze
  end
