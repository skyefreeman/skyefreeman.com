class IdeasController < ApplicationController
  before_action :require_authentication, only: %i[show new create edit update destroy]
  before_action :set_idea, only: %i[show edit update destroy]

  def index
    @ideas = Idea.order(updated_at: :desc)
  end

  def show
  end

  def new
    @idea = Idea.new
  end

  def create
    @idea = Idea.new(idea_params)
    if @idea.save
      redirect_to ideas_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @idea.update(idea_params)
      redirect_to ideas_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @idea.destroy
    redirect_to ideas_path
  end

  private

  def set_idea
    @idea = Idea.find(params[:id])
  end

  def idea_params
    params.require(:idea).permit(:title, :output_url, :tag_names)
  end
end
