# frozen_string_literal: true

module ApplicationHelper
  def default_meta_tags(page_image_path: nil)
    {
      site: 'cocopos',
      title: '心のポスト(目安箱)',
      reverse: true,
      charset: 'utf-8',
      description: '心の記録を花のように咲かせる。未来宣言箱・心の整理箱・感謝箱で気持ちを残せるアプリです。',
      keywords: '心の目安箱,感情,日記,感謝,未来宣言,整理',
      canonical: request.original_url,
      separator: '|',
      og: build_og_meta(page_image_path),
      twitter: build_twitter_meta(page_image_path)
    }
  end

  def flash_tone_class(level, message)
    text = message.to_s

    return 'flash-alert' if logout_message?(text)
    return 'flash-notice' if login_message?(text)

    level.to_sym == :alert ? 'flash-alert' : 'flash-notice'
  end

  private

  def login_message?(text)
    text.match?(/ログイン|signed in/i)
  end

  def logout_message?(text)
    text.match?(/ログアウト|signed out/i)
  end

  def build_og_meta(page_image_path)
    {
      site_name: :site,
      title: :title,
      description: :description,
      type: 'website',
      url: request.original_url,
      image: resolved_image_url(page_image_path),
      locale: 'ja_JP'
    }
  end

  def build_twitter_meta(page_image_path)
    {
      card: 'summary_large_image',
      image: resolved_image_url(page_image_path)
    }
  end

  def resolved_image_url(page_image_path)
    path = page_image_path.presence || '/ogp.jpg'
    image_url(path)
  end
end
