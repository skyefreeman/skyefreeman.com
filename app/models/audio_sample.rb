class AudioSample < ApplicationRecord
  MAX_AUDIO_FILE_SIZE = 20.megabytes
  MP3_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/x-mp3].freeze

  has_one_attached :audio_file, service: lambda { |_audio_sample|
    Rails.env.production? ? :amazon : Rails.configuration.active_storage.service
  }

  normalizes :url_slug, with: ->(url_slug) { url_slug.strip.presence }

  validates :title, presence: true
  validates :description, presence: true
  validates :url_slug, uniqueness: true, allow_nil: true
  validates :duration_seconds, presence: true
  validates :duration_seconds, numericality: { greater_than: 0 }, allow_nil: true
  validates :latitude, numericality: { in: -90..90 }, allow_nil: true
  validates :longitude, numericality: { in: -180..180 }, allow_nil: true
  validate :audio_file_is_attached
  validate :audio_file_is_mp3
  validate :audio_file_is_within_size_limit

  def to_param
    url_slug.presence || super
  end

  private

  def audio_file_is_attached
    errors.add(:audio_file, "must be attached") unless audio_file.attached?
  end

  def audio_file_is_mp3
    return unless audio_file.attached?
    return if MP3_CONTENT_TYPES.include?(audio_file.blob.content_type) && audio_file.filename.extension_without_delimiter.downcase == "mp3"

    errors.add(:audio_file, "must be an MP3")
  end

  def audio_file_is_within_size_limit
    return unless audio_file.attached?
    return if audio_file.blob.byte_size <= MAX_AUDIO_FILE_SIZE

    errors.add(:audio_file, "must be 20 MiB or smaller")
  end
end
