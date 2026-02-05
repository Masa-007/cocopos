# frozen_string_literal: true
seed_uuid = SecureRandom.uuid
seed_password = SecureRandom.uuid

user = User.create!(
  name: "user-#{seed_uuid}",
  email: "#{seed_uuid}@example.invalid",
  password: seed_password,
  password_confirmation: seed_password
)

post = user.posts.create!(
  title: "title-#{SecureRandom.uuid}",
  body: "body-#{SecureRandom.uuid}",
  post_type: 'future',
  comment_allowed: true
)

post.comments.create!(
  user: user,
  content: "comment-#{SecureRandom.uuid}",
  is_anonymous: false
)
