# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Openai::GenerateText do
  let(:prompt) { '元テキスト' }

  let(:client) { instance_double(OpenAI::Client) }
  let(:responses) { instance_double(OpenAI::Resources::Responses) }
  let(:response) { instance_double(OpenaiTestResponse, output_text: output_text) }

  before do
    # openai gem の実体クラスに依存しすぎないよう、テスト用の最小クラスを用意します
    stub_const('OpenaiTestResponse', Class.new do
      def output_text; end
    end)

    allow(OpenAI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:responses).and_return(responses)
    allow(responses).to receive(:create).and_return(response)
  end

  describe '.call' do
    subject(:result) { described_class.call(prompt: prompt) }

    context 'when output contains the separator（区切り文字で分割した2案を返す）' do
      let(:output_text) { "案1\n#{described_class::SEPARATOR}\n案2" }

      it 'returns two options' do
        expect(result.success?).to be(true)
        expect(result.options).to eq(%w[案1 案2])
      end
    end

    context 'when output contains only one option（出力が1案のみの場合は元プロンプトを補完して2案にする）' do
      let(:output_text) { "案1だけ\n" }

      it 'fills the second option with the original prompt' do
        expect(result.success?).to be(true)
        expect(result.options).to eq(['案1だけ', prompt])
      end
    end

    context 'when output text is blank（レスポンス本文が空の場合は失敗扱いになる）' do
      let(:output_text) { '' }

      it 'returns failure' do
        expect(result.success?).to be(false)
        expect(result.error).to eq('本文の生成に失敗しました')
      end
    end

    context 'when the API call raises an error（API呼び出しが失敗した場合は失敗オブジェクトを返す）' do
      let(:output_text) { 'unused' }

      before do
        allow(responses).to receive(:create).and_raise(StandardError, 'boom')
      end

      it 'returns failure' do
        expect(result.success?).to be(false)
        expect(result.error).to eq('本文の生成に失敗しました')
      end
    end
  end
end
