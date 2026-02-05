# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Openai::GenerateText do
  let(:client) { instance_double(OpenAI::Client) }
  let(:responses_api) { instance_double('OpenAI::ResponsesAPI') }

  before do
    allow(OpenAI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:responses).and_return(responses_api)
  end

  it '区切り文字で分割した2案を返す' do
    response = instance_double('OpenAIResponse', output_text: "案1#{described_class::SEPARATOR}案2")
    allow(responses_api).to receive(:create).and_return(response)

    result = described_class.call(prompt: '原文')

    expect(result.success?).to be(true)
    expect(result.options).to eq(%w[案1 案2])
  end

  it '出力が1案のみの場合は元プロンプトを補完して2案にする' do
    response = instance_double('OpenAIResponse', output_text: '案1のみ')
    allow(responses_api).to receive(:create).and_return(response)

    result = described_class.call(prompt: '原文')

    expect(result.success?).to be(true)
    expect(result.options).to eq(['案1のみ', '原文'])
  end

  it 'API呼び出しが失敗した場合は失敗オブジェクトを返す' do
    allow(responses_api).to receive(:create).and_raise(StandardError, 'network error')

    result = described_class.call(prompt: '原文')

    expect(result.success?).to be(false)
    expect(result.error).to eq('本文の生成に失敗しました')
  end

  it 'レスポンス本文が空の場合は失敗扱いになる' do
    response = instance_double('OpenAIResponse', output_text: '')
    allow(responses_api).to receive(:create).and_return(response)

    result = described_class.call(prompt: '原文')

    expect(result.success?).to be(false)
    expect(result.error).to eq('本文の生成に失敗しました')
  end
end
