# app/controllers/flowers_controller.rb
class FlowersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    current_user.flowers.create(post: @post)
    @post.reload  # ← 追加
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to posts_path }
    end
  end

  def destroy
    current_user.flowers.find_by(post: @post)&.destroy
    @post.reload 
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to posts_path }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
