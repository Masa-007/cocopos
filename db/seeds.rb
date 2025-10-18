# frozen_string_literal: true

docker compose exec web rails c
User.create(name: 'Masa', email: 'masa@example.com')
Post.create(user_id: 1, body: 'これはテスト投稿です', post_type: 'future', opinion_needed: true)
Comment.create(user_id: 1, post_id: 1, body: 'いいですね！', is_anonymous: false)
