class TagsController < ApplicationController
  allow_unauthenticated_access

  def index
    @tags = Tag.order(:name)
  end

  def show
    @tag = Tag.find_by!(name: params[:name])
    @posts = @tag.posts.where.not(published_at: nil).order(published_at: :desc)
    @notes = @tag.notes.order(updated_at: :desc)
    @ideas = @tag.ideas.order(updated_at: :desc)
    @links = @tag.links.order(created_at: :desc)
  end
end
