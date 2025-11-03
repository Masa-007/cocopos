# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    @posts = Post.includes(:user)
    @posts = filter_by_visibility(@posts)
    @posts = filter_by_type(@posts)
    @posts = sort_posts(@posts)
    @posts = paginate_posts(@posts)
  end

  def show
    redirect_to posts_path, alert: 'この投稿は非公開です' and return if private_post_blocked?

    @comments = @post.comments.includes(:user)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    disable_comment_if_private(@post)

    respond_to do |format|
      if @post.save
        success_response(format, @post)
      else
        failure_response(format, @post)
      end
    end
  end

  def edit; end

  def update
    updated_params = prepare_updated_params(@post, post_params)
    if @post.update(updated_params)
      redirect_to @post, notice: '投稿を更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: '投稿を削除しました'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to posts_path, alert: '権限がありません' unless @post.user == current_user
  end

  def filter_by_visibility(posts)
    posts.where(is_public: true)
  end

  def filter_by_type(posts)
    return posts if params[:filter].blank? || params[:filter] == 'all'

    posts.where(post_type: params[:filter])
  end

  def sort_posts(posts)
    case params[:sort]
    when 'old'
      posts.order(created_at: :asc)
    else
      posts.order(created_at: :desc)
    end
  end

  def paginate_posts(posts)
    posts.page(params[:page]).per(10)
  end

  def private_post_blocked?
    !@post.is_public && (!user_signed_in? || @post.user != current_user)
  end

  def disable_comment_if_private(post)
    post.comment_allowed = false unless post.is_public
  end

  def success_response(format, post)
    format.html { redirect_to post, notice: '投稿を作成しました' }
    format.json { render json: { success: true }, status: :created }
  end

  def failure_response(format, post)
    format.html { render :new, status: :unprocessable_entity }
    format.json do
      render json: { success: false, errors: post.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def prepare_updated_params(post, params)
    updated = params.dup
    updated[:is_public] = fetch_bool(updated, :is_public, post.is_public)
    updated[:comment_allowed] = fetch_bool(updated, :comment_allowed, post.comment_allowed)
    updated[:comment_allowed] &&= updated[:is_public]
    effective_type = (updated[:post_type] || post.post_type).to_s
    updated[:opinion_needed] = nil unless effective_type == 'organize'
    updated
  end

  def fetch_bool(hash, key, fallback)
    return fallback unless hash.key?(key)

    ActiveModel::Type::Boolean.new.cast(hash[key])
  end

  def post_params
    permitted = params.require(:post).permit(
      :title,
      :body,
      :post_type,
      :opinion_needed,
      :is_anonymous,
      :is_public,
      :comment_allowed
    )
    cast_booleans(permitted, %i[is_public comment_allowed opinion_needed])
  end

  def cast_booleans(permitted, keys)
    bool = ActiveModel::Type::Boolean.new
    keys.each do |key|
      permitted[key] = bool.cast(permitted[key]) if permitted.key?(key)
    end
    permitted
  end
end
