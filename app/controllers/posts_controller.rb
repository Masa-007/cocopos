class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @posts = Post.includes(:user).recent

    if params[:filter].present?
      @posts = @posts.where(post_type: params[:filter])
    end
  end

  def show
    # @postはbefore_actionで設定済み
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      respond_to do |format|
        format.json { render json: { success: true, post_id: @post.id }, status: :created }
        format.html { redirect_to @post, notice: '投稿が完了しました' }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @post.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    # @postはbefore_actionで設定済み
  end

  def update
    if @post.update(post_params)
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
    unless @post.user == current_user
      redirect_to posts_path, alert: '権限がありません'
    end
  end

  def post_params
    params.require(:post).permit(:body, :post_type, :opinion_needed, :is_anonymous)
  end
end
