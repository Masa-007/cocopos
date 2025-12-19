# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # 投稿一覧
  def index
    @posts = Post.includes(:user, comments: :user, flowers: :user)
    @posts = filter_by_visibility(@posts)
    @posts = filter_by_type(@posts)

    if params[:q].present?
      query = "%#{params[:q]}%"
      @posts = @posts.where('title ILIKE :q OR body ILIKE :q', q: query)
    end

    @posts = sort_posts(@posts)
    @posts = paginate_posts(@posts)
  end

  # 投稿詳細
  def show
    redirect_to posts_path, alert: t('posts.alerts.private') and return if private_post_blocked?

    @comments = @post.comments.includes(:user, :flowers)
  end

  # 新規投稿フォーム
  def new
    @post = Post.new
    @show_loading = true
  end

  # 投稿作成
  def create
    @post = current_user.posts.build(post_params_for_create)
    disable_comment_if_private(@post)

    if request.format.json?
      if @post.save
        render json: {
          success: true,
          data: {
            id: @post.id,
            post_type: @post.post_type,
            mood: @post.mood
          }
        }, status: :ok
      else
        render json: {
          success: false,
          errors: @post.errors.full_messages
        }, status: :unprocessable_entity
      end
    elsif @post.save
      redirect_to post_path(@post), notice: t('posts.notices.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # 編集フォーム
  def edit; end

  # 投稿更新
  def update
    updated_params = prepare_updated_params(@post, post_params_for_update)

    if @post.update(updated_params)
      @post.reload
      redirect_after_action(@post, t('posts.notices.updated'))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 投稿削除
  def destroy
    @post.destroy
    redirect_after_action(nil, t('posts.notices.deleted'))
  end

  private

  # 投稿取得
  def set_post
    @post = Post.includes(:user, comments: :user, flowers: :user).find(params[:id])
  end

  # 権限確認
  def authorize_user!
    return if @post.user == current_user || current_user.admin?

    redirect_to posts_path, alert: t('posts.alerts.unauthorized')
  end

  # リダイレクト処理
  def redirect_after_action(post, message)
    if params[:from] == 'mypage'
      redirect_to mypage_posts_path, notice: message
    elsif post.present?
      redirect_to post_path(post, from: params[:from]), notice: message
    else
      redirect_to posts_path, notice: message
    end
  end

  # 公開投稿のみ取得
  def filter_by_visibility(posts)
    posts.where(is_public: true)
  end

  # post_type フィルター
  def filter_by_type(posts)
    return posts if params[:filter].blank? || params[:filter] == 'all'

    posts.where(post_type: params[:filter])
  end

  # 並び替え
  def sort_posts(posts)
    case params[:sort]
    when 'old'
      posts.order(created_at: :asc)
    else
      posts.order(created_at: :desc)
    end
  end

  # ページネーション
  def paginate_posts(posts)
    posts.page(params[:page]).per(10)
  end

  # 非公開ならコメント不可
  def disable_comment_if_private(post)
    post.comment_allowed = false unless post.is_public
  end

  # 非公開閲覧制御
  def private_post_blocked?
    !@post.is_public && (!user_signed_in? || @post.user != current_user)
  end

  # update 用パラメータ整形
  def prepare_updated_params(post, params)
    updated = params.dup

    updated[:is_public] = fetch_bool(updated, :is_public, post.is_public)

    updated[:comment_allowed] = if updated[:is_public]
                                  fetch_bool(updated, :comment_allowed, post.comment_allowed)
                                else
                                  false
                                end

    updated[:comment_allowed] = updated[:comment_allowed] == true

    updated.delete(:post_type)

    updated
  end

  # 真偽値キャスト
  def fetch_bool(hash, key, fallback)
    return fallback unless hash.key?(key)

    ActiveModel::Type::Boolean.new.cast(hash[key])
  end

  # create 用パラメータ
  def post_params_for_create
    permitted = params.require(:post).permit(
      :title,
      :body,
      :post_type,
      :is_anonymous,
      :is_public,
      :comment_allowed,
      :mood,
      :deadline,
      milestones_attributes: %i[
        id
        title
        completed
        _destroy
      ]
    )
    cast_booleans(permitted, %i[is_public comment_allowed])
  end

  # update 用パラメータ
  def post_params_for_update
    permitted = params.require(:post).permit(
      :title,
      :body,
      :is_anonymous,
      :is_public,
      :comment_allowed,
      :mood,
      :deadline,
      milestones_attributes: %i[
        id
        title
        completed
        _destroy
      ]
    )
    cast_booleans(permitted, %i[is_public comment_allowed])
  end

  # 真偽値キャスト
  def cast_booleans(permitted, keys)
    bool = ActiveModel::Type::Boolean.new
    keys.each do |key|
      permitted[key] = bool.cast(permitted[key]) if permitted.key?(key)
    end
    permitted
  end
end
