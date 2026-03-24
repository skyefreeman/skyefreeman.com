class PostsController < ApplicationController
  before_action :require_authentication, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]

  def blog
    @posts = Post.order(published_at: :desc)
    @posts = @posts.where.not(published_at: nil) unless authenticated?
  end

  def show
  end

  def show_by_date_slug
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @post = Post.find_by!(url_slug: params[:slug], published_at: date.beginning_of_day..date.end_of_day)
    render :show
  rescue ArgumentError
    raise ActiveRecord::RecordNotFound
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @publishing = params[:publish].present?
    @post.published_at = Time.current if @publishing
    if @post.save
      redirect_to @post
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @post.assign_attributes(post_params)
    @publishing = params[:publish].present?
    @post.published_at = Time.current if @publishing
    if @post.save
      redirect_to @post
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to blog_path
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(
      :title, :deleted_at, :url_slug,
      :body, :header_attachment
    )
  end
end
