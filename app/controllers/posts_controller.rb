class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_post,          only: %i[show edit update destroy]
  before_action :authorize_user!,   only: %i[edit update destroy]

  # === 投稿一覧 ===
  def index
    @posts = Post.includes(:user)

    # 公開設定
    if user_signed_in?
      # 自分の投稿 + 公開投稿を表示
      @posts = @posts.where("is_public = ? OR user_id = ?", true, current_user.id)
    else
      # 未ログイン時は公開投稿のみ
      @posts = @posts.where(is_public: true)
    end

    # 絞り込み
    if params[:filter].present? && params[:filter] != "all"
      @posts = @posts.where(post_type: params[:filter])
    end

    # ソート（デフォルト：新着順）
    @posts =
      case params[:sort]
      when "old" then @posts.order(created_at: :asc)
      else            @posts.order(created_at: :desc)
      end

    # ページネーション（1ページ10件）
    @posts = @posts.page(params[:page]).per(10)
  end

  # === 投稿詳細 ===
  def show
    # 非公開投稿は本人のみ閲覧可
    if !@post.is_public && (!user_signed_in? || @post.user != current_user)
      redirect_to posts_path, alert: "この投稿は非公開です"
    end
  end

  def new
    @post = Post.new
  end

  # === 投稿作成 ===
  def create
    @post = current_user.posts.build(post_params)

    # 非公開投稿ではコメント募集を無効化
    @post.comment_allowed = false unless @post.is_public

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "投稿を作成しました" }
        format.json { render json: { success: true }, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @post.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # === 投稿編集 ===
  def edit; end

  # === 投稿更新 ===
  def update
    updated_params = post_params

    # --- 保険：ラジオ未送信でも落ちないように現値で補完 ---
    if updated_params[:is_public].nil?
      updated_params[:is_public] = @post.is_public
    end
    if updated_params[:comment_allowed].nil?
      updated_params[:comment_allowed] = @post.comment_allowed
    end

    # 非公開ならコメント募集は強制OFF
    updated_params[:comment_allowed] = false unless updated_params[:is_public]

    # post_type の有効値（未送信なら現値）
    effective_type = (updated_params[:post_type] || @post.post_type).to_s

    # 心の整理箱以外では opinion_needed は無効化（DBを汚さないためにnilへ）
    updated_params[:opinion_needed] = nil unless effective_type == "organize"

    if @post.update(updated_params)
      redirect_to @post, notice: "投稿を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # === 投稿削除 ===
  def destroy
    @post.destroy
    redirect_to posts_path, notice: "投稿を削除しました"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_user!
    redirect_to posts_path, alert: "権限がありません" unless @post.user == current_user
  end

  # === Strong Parameters ===
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

    bool = ActiveModel::Type::Boolean.new
    # "true"/"false" を boolean に変換
    permitted[:is_public]       = bool.cast(permitted[:is_public])       if permitted.key?(:is_public)
    permitted[:comment_allowed] = bool.cast(permitted[:comment_allowed]) if permitted.key?(:comment_allowed)
    permitted[:opinion_needed]  = bool.cast(permitted[:opinion_needed])  if permitted.key?(:opinion_needed)

    permitted
  end
end
