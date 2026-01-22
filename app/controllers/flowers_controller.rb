# frozen_string_literal: true

class FlowersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_flowerable
  before_action :ensure_flowerable_visible

  def create
    current_user.flowers.find_or_create_by(flowerable: @flowerable)
    @flowerable.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: '花を贈りました🌸' }
    end
  end

  def destroy
    flower = current_user.flowers.find_by(flowerable: @flowerable)
    flower&.destroy
    @flowerable.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: '花を取り消しました🌿' }
    end
  end

  private

  def set_flowerable
    @flowerable =
      if params[:comment_id]
        Comment.find(params[:comment_id])
      elsif params[:post_id]
        Post.find(params[:post_id])
      else
        raise ActiveRecord::RecordNotFound, 'flowerable not found'
      end
  end

  def ensure_flowerable_visible
    post = @flowerable.is_a?(Comment) ? @flowerable.post : @flowerable
    return if post.is_public?
    return if post.user == current_user || current_user.admin?

    redirect_to posts_path, alert: t('posts.alerts.private')
  end
end
