require "test_helper"

class AuthenticatedDirectUploadsControllerTest < ActionDispatch::IntegrationTest
  test "direct upload authorization requires authentication" do
    post rails_direct_uploads_url, params: { blob: blob_attributes }

    assert_redirected_to new_session_path
  end

  test "authenticated user can authorize a direct upload" do
    sign_in_as(users(:one))

    assert_difference("ActiveStorage::Blob.count") do
      post rails_direct_uploads_url, params: { blob: blob_attributes }
    end
    assert_response :success
    assert response.parsed_body["signed_id"].present?
    assert response.parsed_body.dig("direct_upload", "url").present?
  end

  test "audio sample direct uploads require authentication" do
    post audio_sample_direct_uploads_url, params: { blob: blob_attributes }

    assert_redirected_to new_session_path
  end

  test "audio sample direct uploads use the environment storage service" do
    sign_in_as(users(:one))

    post audio_sample_direct_uploads_url, params: { blob: blob_attributes }

    assert_response :success
    assert_equal Rails.configuration.active_storage.service.to_s, ActiveStorage::Blob.last.service_name
  end

  private

  def blob_attributes
    {
      filename: "sample.mp3",
      byte_size: 8,
      checksum: Digest::MD5.base64digest("mp3 data"),
      content_type: "audio/mpeg",
      metadata: {}
    }
  end
end
