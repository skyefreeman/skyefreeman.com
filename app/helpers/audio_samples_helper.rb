module AudioSamplesHelper
  def format_audio_duration(duration_seconds)
    total_seconds = duration_seconds.to_i
    hours, remaining_seconds = total_seconds.divmod(1.hour)
    minutes, seconds = remaining_seconds.divmod(1.minute)

    return format("%d:%02d:%02d", hours, minutes, seconds) if hours.positive?

    format("%d:%02d", minutes, seconds)
  end
end
