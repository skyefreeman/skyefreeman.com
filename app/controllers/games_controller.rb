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
      respond_to do |format|
        format.html { redirect_to @game }
        format.json { render json: { location: game_path(@game) } }
      end
    else
      render_save_errors(:new)
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      respond_to do |format|
        format.html { redirect_to @game }
        format.json { render json: { location: game_path(@game) } }
      end
    else
      render_save_errors(:edit)
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path
  end

  private

  def render_save_errors(template)
    respond_to do |format|
      format.html { render template, status: :unprocessable_entity }
      format.json { render json: { errors: @game.errors.full_messages }, status: :unprocessable_entity }
    end
  end

  def set_game
    @game = Game.find_by(url_slug: params[:id]) || Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(
      :title, :description, :url_slug, :cover_image,
      :linux_package, :macos_package, :windows_package,
      :download_url_itch
    )
  end
end
