class PostsController < ApplicationController
  before_action :require_authentication, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]

  def blog
    @posts = Post.order(published_at: :desc)
    @posts = @posts.where.not(published_at: nil) unless authenticated?
  end

  def by_year
    @year = params[:year].to_i
    @posts = published_posts_in_range(Date.new(@year).beginning_of_year..Date.new(@year).end_of_year)
  end

  def by_month
    @year  = params[:year].to_i
    @month = params[:month].to_i
    @posts = published_posts_in_range(Date.new(@year, @month).beginning_of_month..Date.new(@year, @month).end_of_month)
  end

  def by_day
    @year  = params[:year].to_i
    @month = params[:month].to_i
    @day   = params[:day].to_i
    date   = Date.new(@year, @month, @day)
    @posts = published_posts_in_range(date.beginning_of_day..date.end_of_day)
  rescue ArgumentError
    raise ActiveRecord::RecordNotFound
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

  def published_posts_in_range(range)
    Post.where(published_at: range).order(published_at: :desc)
  end

  def post_params
    params.require(:post).permit(
      :title, :deleted_at, :url_slug,
      :body, :header_attachment
    )
  end
end
