# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MypageInsights do
  let(:host_class) do
    Class.new do
      include MypageInsights

      def expose(method_name, *args, **kwargs)
        send(method_name, *args, **kwargs)
      end
    end
  end

  let(:insights) { host_class.new }

  describe '#build_mood_insight' do
    it '投稿数が2件未満なら記録不足メッセージを返す' do
      mood_posts = [Post.new(mood: :happy)]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('記録がまだ少なめ')
    end

    it '後半の平均スコアが低いと下降気味メッセージを返す' do
      mood_posts = [
        Post.new(mood: :excited),
        Post.new(mood: :happy),
        Post.new(mood: :sad),
        Post.new(mood: :angry)
      ]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('下降気味')
    end

    it '後半の平均スコアが高いと上向きメッセージを返す' do
      mood_posts = [
        Post.new(mood: :sad),
        Post.new(mood: :tired),
        Post.new(mood: :happy),
        Post.new(mood: :excited)
      ]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('上向き')
    end

    it 'ネガティブ気分比率が高いと注意メッセージを返す' do
      mood_posts = [
        Post.new(mood: :tired),
        Post.new(mood: :sad),
        Post.new(mood: :anxious),
        Post.new(mood: :happy),
        Post.new(mood: :calm)
      ]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('悩みや疲れが多い傾向')
    end

    it '平均スコアが低いと疲れが多いメッセージを返す' do
      mood_posts = [
        Post.new(mood: :tired),
        Post.new(mood: :frustrated),
        Post.new(mood: :sad),
        Post.new(mood: :calm)
      ]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('疲れやモヤモヤが多かった')
    end

    it 'それ以外は安定メッセージを返す' do
      mood_posts = [
        Post.new(mood: :calm),
        Post.new(mood: :happy),
        Post.new(mood: :calm),
        Post.new(mood: :happy)
      ]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('気分は安定')
    end

    it 'ネガティブ比率が0.6ちょうどでも注意メッセージを返す' do
      mood_posts = [
        Post.new(mood: :tired),
        Post.new(mood: :sad),
        Post.new(mood: :angry),
        Post.new(mood: :happy),
        Post.new(mood: :calm)
      ]

      result = insights.expose(:build_mood_insight, mood_posts)

      expect(result).to include('悩みや疲れが多い傾向')
    end
  end

  describe '#build_future_insight' do
    it '未来投稿が空なら未投稿メッセージを返す' do
      result = insights.expose(:build_future_insight, [])

      expect(result).to include('未来宣言箱の投稿がありません')
    end

    it '未達成フィルターで未達が0件かつ達成済みがあると達成メッセージを返す' do
      all_posts = [Post.new(progress: 100), Post.new(progress: 100)]

      result = insights.expose(
        :build_future_insight,
        [],
        all_future_posts: all_posts,
        todo_filter: 'unachieved'
      )

      expect(result).to include('今月は')
      expect(result).to include('目標を達成しています。')
      expect(result).to include('現在未達の目標はありません。')
      expect(result).to include('ぜひ新しい目標を立ててみましょう。')
    end

    it '期限が近く進捗が低い投稿があると期限メッセージを返す' do
      posts = [Post.new(deadline: Date.current + 2.days, progress: 10)]

      result = insights.expose(:build_future_insight, posts)

      expect(result).to include('期限が近いTODO')
    end

    it '平均進捗が70%以上なら順調メッセージを返す' do
      posts = [Post.new(progress: 80), Post.new(progress: 90)]

      result = insights.expose(:build_future_insight, posts)

      expect(result).to include('進捗は順調')
    end

    it '平均進捗が30%以下なら余白メッセージを返す' do
      posts = [Post.new(progress: 10), Post.new(progress: 20)]

      result = insights.expose(:build_future_insight, posts)

      expect(result).to include('まだ余白が多い')
    end

    it '中間の進捗なら着実メッセージを返す' do
      posts = [Post.new(progress: 40), Post.new(progress: 60)]

      result = insights.expose(:build_future_insight, posts)

      expect(result).to include('着実に進んでいます')
    end

    it '期限が近くても進捗が50以上なら期限メッセージにならない' do
      posts = [Post.new(deadline: Date.current + 2.days, progress: 50)]

      result = insights.expose(:build_future_insight, posts)

      expect(result).not_to include('期限が近いTODO')
    end
  end

  describe '#build_thanks_recipients_summary と #build_thanks_insight' do
    it '感謝タグを集計して件数降順で返す' do
      posts = [
        Post.new(post_type: :thanks, thanks_recipient: :friend),
        Post.new(post_type: :thanks, thanks_recipient: :friend),
        Post.new(post_type: :thanks, thanks_recipient: :family)
      ]

      summary = insights.expose(:build_thanks_recipients_summary, posts)

      expect(summary).to eq([
                              { label: '友人', count: 2 },
                              { label: '家族', count: 1 }
                            ])
    end

    it '集計が空ならデフォルトメッセージを返す' do
      result = insights.expose(:build_thanks_insight, [])

      expect(result).to include('記録がまだ少なめ')
    end

    it '集計がある場合は最多対象への感謝メッセージを返す' do
      summary = [{ label: '友人', count: 3 }]

      result = insights.expose(:build_thanks_insight, summary)

      expect(result).to include('友人への感謝が多い')
    end

    it '感謝タグが同数の場合はラベル昇順で返す' do
      posts = [
        Post.new(post_type: :thanks, thanks_recipient: :family),
        Post.new(post_type: :thanks, thanks_recipient: :friend)
      ]

      summary = insights.expose(:build_thanks_recipients_summary, posts)

      expect(summary).to eq([
                              { label: '友人', count: 1 },
                              { label: '家族', count: 1 }
                            ])
    end
  end
end
