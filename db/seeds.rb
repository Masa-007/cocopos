# frozen_string_literal: true

return if Rails.env.test?

demo_email = 'cocopos.demo@example.com'

demo_user = User.find_or_initialize_by(email: demo_email)

demo_user.name = 'お試しさん'
demo_user.password = 'password'
demo_user.password_confirmation = 'password'
demo_user.save!

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
  deadline: Date.current + 7,
  comment_allowed: true
)

post.comments.create!(
  user: user,
  content: "comment-#{SecureRandom.uuid}",
  is_anonymous: false
)
