# frozen_string_literal: true

user = User.create!(
  name: 'Masa',
  email: 'masa@example.com',
  password: 'password',
  password_confirmation: 'password'
)

post = user.posts.create!(
  body: 'これはテスト投稿です',
  post_type: 'future',
  comment_allowed: true
)

post.comments.create!(
  user: user,
  body: 'いいですね！',
  is_anonymous: false
)
