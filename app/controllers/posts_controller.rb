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
    redirect_to posts_path, alert: t('posts.alerts.private') and return if private_post_blocked?
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
      @post.reload
      redirect_after_action(@post, t('posts.notices.updated'))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_after_action(nil, t('posts.notices.deleted'))
  end

  private

  def redirect_after_action(post, message)
    if params[:from] == 'mypage'
      redirect_to mypage_posts_path, notice: message
    elsif post.present?
      redirect_to post_path(post, from: params[:from]), notice: message
    else
      redirect_to posts_path, notice: message
    end
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to posts_path, alert: t('posts.alerts.unauthorized') unless @post.user == current_user
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
    format.html { redirect_to post_path(post, from: params[:from]), notice: t('posts.notices.created') }
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

    if updated[:is_public]
      updated[:comment_allowed] = fetch_bool(updated, :comment_allowed, post.comment_allowed)
    else
      updated[:comment_allowed] = false
    end

    updated[:comment_allowed] =
      if updated[:comment_allowed] == true
        true
      else
        false
      end

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
      :is_anonymous,
      :is_public,
      :comment_allowed
    )
    cast_booleans(permitted, %i[is_public comment_allowed])
  end

  def cast_booleans(permitted, keys)
    bool = ActiveModel::Type::Boolean.new
    keys.each do |key|
      permitted[key] = bool.cast(permitted[key]) if permitted.key?(key)
    end
    permitted
  end
end
