# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # コメント作成
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: 'コメントを投稿しました。'
    else
      redirect_to post_path(@post), alert: 'コメントの投稿に失敗しました。'
    end
  end

  # コメント編集ページ
  def edit; end

  # コメント更新
  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post), notice: 'コメントを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # コメント削除
  def destroy
    @comment.destroy
    redirect_to post_path(@post), notice: 'コメントを削除しました。'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def authorize_user!
    redirect_to post_path(@post), alert: '編集権限がありません。' unless @comment.user == current_user
  end

  def comment_params
    params.require(:comment).permit(:content, :is_anonymous)
  end
end
