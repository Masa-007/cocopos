# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def index
    @posts = Post.includes(:user, comments: :user, flowers: :user)
    @posts = filter_by_visibility(@posts)
    @posts = filter_by_type(@posts)

    if params[:q].present?
      query = "%#{params[:q]}%"
      @posts = @posts.where('title ILIKE :q OR body ILIKE :q', q: query)
    end

    @posts = apply_sub_filter(@posts)
    @posts = sort_posts(@posts)
    @posts = paginate_posts(@posts)

    @page_title = '投稿一覧 | cocopos'
    @page_description = 'cocoposで公開されている投稿一覧です。'
  end

  def show
    redirect_to posts_path, alert: t('posts.alerts.private') and return if private_post_blocked?

    @comments = @post.comments.includes(:user, :flowers)
  end

  # 新規投稿フォーム
  def new
    @post = current_user.posts.new(
      post_type: params[:post_type].presence || :future,
      is_public: true,
      comment_allowed: true
    )
    @show_loading = true
  end

  def edit; end

  # 投稿作成
  def create
    @post = current_user.posts.build(post_params_for_create)
    disable_comment_if_private(@post)
    validate_required_fields_by_post_type(@post)

    saved = @post.errors.empty? && @post.save

    return render_create_json(@post, saved) if request.format.json?

    if saved
      redirect_to post_path(@post), notice: t('posts.notices.created')
    else
      flash.now[:alert] = [t('posts.alerts.failed'), @post.errors.full_messages.to_sentence].join(' ')
      render :new, status: :unprocessable_entity
    end
  end

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

  def render_create_json(post, saved)
    if saved
      render json: { success: true, data: { id: post.id, post_type: post.post_type, mood: post.mood } }, status: :ok
    else
      render json: { success: false, errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # 投稿取得
  def set_post
    @post = Post.includes(:user, comments: :user, flowers: :user).find_by!(public_uuid: params[:public_uuid])
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

  def apply_sub_filter(posts)
    case params[:filter]
    when 'future'
      case params[:sub_filter]
      when 'future_achieved'
        posts.where(progress: 100)
      when 'future_unachieved'
        posts.where(progress: nil).or(posts.where.not(progress: 100))
      else
        posts
      end
    when 'organize'
      return posts if params[:sub_filter].blank?

      posts.where(mood: params[:sub_filter])
    when 'thanks'
      return posts if params[:sub_filter].blank?

      posts.where(thanks_recipient: params[:sub_filter])
    else
      posts
    end
  end

  # ページネーション
  def paginate_posts(posts)
    posts.page(params[:page]).per(posts_per_page)
  end

  def posts_per_page
    mobile_device? ? 10 : 9
  end

  def mobile_device?
    request.user_agent.to_s.match?(/Mobile|Android|iPhone/i)
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

  def validate_required_fields_by_post_type(post)
    return unless post.future?
    return if post.deadline.present?

    post.errors.add(:deadline, 'を入力してください')
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
      :thanks_recipient,
      :thanks_recipient_other,
      :deadline,
      :progress,
      milestones_attributes: %i[id title completed _destroy]
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
      :thanks_recipient,
      :thanks_recipient_other,
      :deadline,
      :progress,
      milestones_attributes: %i[id title completed _destroy]
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
