class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @posts = Post.order(created_at: :desc).limit(10)
  end
  def about; end
  def projects; end
end
