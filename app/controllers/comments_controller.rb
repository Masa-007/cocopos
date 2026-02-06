# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :ensure_commentable_post, only: %i[create]
  before_action :ensure_comments_allowed, only: %i[create]
  before_action :set_comment, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # コメント編集フォーム
  def edit; end

  # コメント作成
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: t('comments.notices.created')
    else
      redirect_to post_path(@post), alert: t('comments.alerts.failed')
    end
  end

  # コメント更新
  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post), notice: t('comments.notices.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # コメント削除
  def destroy
    @comment.destroy
    redirect_to post_path(@post), notice: t('comments.notices.deleted')
  end

  private

  # 投稿セット
  def set_post
    @post = Post.find_by!(public_uuid: params[:post_public_uuid])
  end

  def ensure_commentable_post
    return if @post.is_public?
    return if @post.user == current_user || current_user.admin?

    redirect_to posts_path, alert: t('posts.alerts.private')
  end

  def ensure_comments_allowed
    return if @post.comment_allowed?

    redirect_to post_path(@post), alert: t('comments.alerts.unauthorized')
  end

  # コメントセット
  def set_comment
    @comment = @post.comments.find_by!(public_uuid: params[:id])
  end

  # 編集・削除権限確認
  def authorize_user!
    # 管理者は update（編集）にはアクセス不可、destroy（削除）はOK
    return if current_user.admin? && action_name == 'destroy'

    # 投稿者は編集・削除ともにアクセス可能
    return if @comment.user == current_user

    # それ以外は権限なし
    redirect_to post_path(@post), alert: t('comments.alerts.unauthorized')
  end

  # Strong Parameters
  def comment_params
    params.require(:comment).permit(:content, :is_anonymous)
  end
end
