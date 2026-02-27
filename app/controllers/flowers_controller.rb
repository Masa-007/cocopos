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
      format.html { redirect_back fallback_location: root_path, notice: t('flowers.notices.created') }
    end
  end

  def destroy
    flower = current_user.flowers.find_by(flowerable: @flowerable)
    flower&.destroy
    @flowerable.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path, notice: t('flowers.notices.destroyed') }
    end
  end

  private

  def set_flowerable
    post_uuid = params[:post_public_uuid].presence || params[:post_id].presence
    comment_uuid =
      params[:comment_public_uuid].presence ||
      params[:public_uuid].presence ||
      params[:comment_id].presence ||
      params[:id].presence

    @post = find_post!(post_uuid) if post_uuid.present?

    if comment_uuid.present?
      raise ActiveRecord::RecordNotFound if @post.nil?

      @flowerable = find_comment!(comment_uuid, @post)
      return
    end

    raise ActiveRecord::RecordNotFound if @post.nil?

    @flowerable = @post
  end

  def find_post!(public_uuid)
    Post.find_by!(public_uuid: public_uuid)
  end

  def find_comment!(public_uuid, post)
    post.comments.find_by!(public_uuid: public_uuid)
  end

  def ensure_flowerable_visible
    post = @flowerable.is_a?(Comment) ? @flowerable.post : @flowerable
    return if post.is_public?
    return if post.user == current_user || (current_user.respond_to?(:admin?) && current_user.admin?)

    redirect_to posts_path, alert: t('posts.alerts.private')
  end
end
