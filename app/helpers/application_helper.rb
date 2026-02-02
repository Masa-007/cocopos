# frozen_string_literal: true

module ApplicationHelper
  def default_meta_tags
    {
      site: 'cocopos',
      title: '心のポスト',
      reverse: true,
      charset: 'utf-8',
      description: '心の記録を花のように咲かせる。未来宣言箱・心の整理箱・感謝箱で気持ちを残せるアプリです。',
      keywords: '心のポスト,感情,日記,感謝,未来宣言,整理',
      canonical: request.original_url,
      separator: '|',
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        image: image_url(@page_image_path.presence || 'cocopos.ogp.jpg'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        image: image_url(@page_image_path.presence || 'cocopos.ogp.jpg')
      }
    }
  end
end
