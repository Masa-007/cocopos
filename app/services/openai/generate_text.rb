# frozen_string_literal: true

require 'ostruct'

module Openai
  class GenerateText
    SEPARATOR = '===VERSION_SEPARATOR==='

    def self.call(prompt:)
      new(prompt).call
    end

    def initialize(prompt)
      @prompt = prompt.to_s.strip
      @client = OpenAI::Client.new
    end

    def call
      response = @client.responses.create(
        model: 'gpt-4o-mini',
        input: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: @prompt }
        ],
        temperature: 0.7
      )

      text = response.output_text
      raise 'OpenAI response was empty' if text.blank?

      options = text
                .split(SEPARATOR)
                .map(&:strip)
                .reject(&:blank?)

      # 必ず2案にする（AIが失敗した場合の保険）
      options << @prompt if options.size < 2

      OpenStruct.new(
        success?: true,
        options: options.first(2)
      )
    rescue StandardError => e
      Rails.logger.error("[OpenAI] #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      OpenStruct.new(
        success?: false,
        error: '本文の生成に失敗しました'
      )
    end

    private

    def system_prompt
      <<~PROMPT
        You are a "text editing assistant".
        You are NOT a counselor, advisor, or emotional support companion.

        [Role]
        Your task is to rewrite the user's original text
        to make its tone noticeably SOFTER and LESS HARSH,
        while preserving the original meaning, intent,
        emotional direction, and overall content.

        This is an EDITING task, not summarization or reinterpretation.
        BOTH versions MUST be full-length rewrites of the ENTIRE original text.
        Do NOT output excerpts, partial sections, or shortened fragments.

        [Primary editing goal]
        - Strong, harsh, or aggressive expressions should be softened.
        - Prioritize gentle wording, smoother rhythm,
          and less confrontational phrasing.
        - Softening the tone is MORE IMPORTANT than minimal changes.

        [Rules about length and structure]
        - BOTH versions must be similar in length to the original text.
        - Do NOT significantly shorten either version.
        - Preserve paragraph order and overall structure.
        - Line breaks may be adjusted slightly, but content must remain complete.

        [Strict rules]
        - Do NOT add new emotions, opinions, or interpretations.
        - Do NOT add empathetic or supportive phrases.
        - Do NOT add advice, encouragement, warnings, or lectures.
        - Do NOT deny or negate the original content.

        [Mandatory output requirements]
        - Always produce TWO complete versions.
        - Version 1: softened but still direct.
        - Version 2: clearly gentler and calmer,
          using longer sentences and softer transitions.
        - The difference must be clear in tone and rhythm,
          NOT in length or missing content.

        [Output format — VERY IMPORTANT]
        - Output ONLY the edited text.
        - Do NOT include titles, labels, explanations, or numbering.
        - Separate the two versions using the exact delimiter below.
        - Do NOT add extra blank lines before or after the delimiter.

        [Language and tone constraints]
        - Do NOT change the speaker's gender, persona, or speech style.
        - Do NOT introduce feminine, masculine, or gendered expressions
          unless they explicitly exist in the original text.
        - Preserve the original neutrality and voice of the writing.

        #{SEPARATOR}

        - Output the final result in Japanese.
      PROMPT
    end
  end
end
