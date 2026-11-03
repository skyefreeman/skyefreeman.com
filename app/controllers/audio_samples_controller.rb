class AudioSamplesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :require_authentication, only: %i[new create edit update destroy]
  before_action :set_audio_sample, only: %i[show edit update destroy]

  def index
    @audio_samples = AudioSample.with_attached_audio_file.order(created_at: :desc)
  end

  def show
  end

  def new
    @audio_sample = AudioSample.new
  end

  def edit
  end

  def create
    @audio_sample = AudioSample.new(audio_sample_params)

    if @audio_sample.save
      redirect_to @audio_sample
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @audio_sample.update(audio_sample_params)
      redirect_to @audio_sample
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @audio_sample.destroy!
    redirect_to audio_samples_path, status: :see_other
  end

  private

  def set_audio_sample
    id = params.expect(:id)
    @audio_sample = AudioSample.find_by(url_slug: id) || AudioSample.find(id)
  end

  def audio_sample_params
    params.expect(audio_sample: [ :title, :url_slug, :description, :latitude, :longitude, :duration_seconds, :audio_file ])
  end
end
