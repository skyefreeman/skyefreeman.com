class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @posts = Post.order(published_at: :desc)
    @posts = @posts.where.not(published_at: nil) unless authenticated?
    @posts = @posts.limit(10)
  end
  def about; end
  def projects; end
end
