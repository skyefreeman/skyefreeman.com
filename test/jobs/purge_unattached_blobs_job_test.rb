require "test_helper"

class PurgeUnattachedBlobsJobTest < ActiveJob::TestCase
  test "purges only unattached blobs older than one day" do
    old_blob = create_blob(created_at: 2.days.ago)
    recent_blob = create_blob(created_at: 1.hour.ago)
    attached_blob = create_blob(created_at: 2.days.ago)
    audio_sample = audio_samples(:one)
    audio_sample.audio_file.attach(attached_blob)

    perform_enqueued_jobs { PurgeUnattachedBlobsJob.perform_now }

    assert_not ActiveStorage::Blob.exists?(old_blob.id)
    assert ActiveStorage::Blob.exists?(recent_blob.id)
    assert ActiveStorage::Blob.exists?(attached_blob.id)
  end

  private

  def create_blob(created_at:)
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("mp3 data"),
      filename: "sample.mp3",
      content_type: "audio/mpeg"
    ).tap { |blob| blob.update_column(:created_at, created_at) }
  end
end
