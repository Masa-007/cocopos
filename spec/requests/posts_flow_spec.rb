# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'future post creation flow' do
    let(:user) do
      User.create!(
        name: 'Flow User',
        email: "flow_user_#{SecureRandom.hex(4)}@example.com",
        password: 'password'
      )
    end

    before do
      host! 'www.cocopos.net'
      sign_in user
    end

    it '投稿を作成し、UUIDベースの詳細ページへリダイレクトされ、show/index に表示される' do
      post posts_path, params: {
        post: {
          title: 'Future plan',
          body: '毎日少しずつ前進する',
          post_type: 'future',
          is_anonymous: '1',
          is_public: '1',
          comment_allowed: '1'
        }
      }

      warn "status=#{response.status}"
      warn "location=#{response.headers['Location'].inspect}"
      warn "content_type=#{response.media_type.inspect}"
      warn "body_tail=#{response.body.to_s[-1200, 1200]}"

      expect(response).to have_http_status(:found)

      location = response.headers['Location']
      expect(location).to be_present
      expect(location).to match(%r{/posts/[0-9a-f\-]{36}})

      created_uuid = location.split('/posts/').last
      created_post = Post.find_by!(public_uuid: created_uuid)

      expect(created_post.public_uuid).to be_present
      expect(created_post.to_param).to eq(created_post.public_uuid)

      get post_path(created_post)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('毎日少しずつ前進する')

      get posts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('毎日少しずつ前進する')
    end
  end
end
