class AudioSampleDirectUploadsController < AuthenticatedDirectUploadsController
  private

  def blob_args
    super.merge(service_name: audio_sample_service_name)
  end

  def audio_sample_service_name
    Rails.env.production? ? :amazon : Rails.configuration.active_storage.service
  end
end
