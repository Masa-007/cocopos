class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @posts = Post.includes(:user).recent

    if params[:filter].present?
      @posts = @posts.where(post_type: params[:filter])
    end
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      respond_to do |format|
        format.json { render json: { success: true, post_id: @post.id }, status: :created }
        format.html { redirect_to posts_path, notice: '投稿が完了しました' }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @post.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :post_type, :opinion_needed, :is_anonymous)
  end
end
