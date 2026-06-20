class GamesController < ApplicationController
  allow_unauthenticated_access only: %i[index show show_by_slug]
  before_action :require_authentication, only: %i[new create edit update destroy]
  before_action :set_game, only: %i[show edit update destroy]

  def index
    @games = Game.order(created_at: :desc)
  end

  def show
  end

  def show_by_slug
    @game = Game.find_by!(url_slug: params[:url_slug])
    render :show
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to @game
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to @game
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path
  end

  private

  def set_game
    @game = Game.find_by(url_slug: params[:id]) || Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(
      :title, :description, :url_slug, :cover_image,
      :download_url_linux, :download_url_macos, :download_url_windows, :download_url_itch
    )
  end
end
