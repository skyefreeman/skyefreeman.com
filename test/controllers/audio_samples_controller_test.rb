require "test_helper"

class AudioSamplesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @audio_sample = audio_samples(:one)
    @audio_sample.audio_file.attach(
      io: StringIO.new("mp3 data"),
      filename: "sample.mp3",
      content_type: "audio/mpeg"
    )
  end

  test "routes audio samples under the audio path" do
    assert_equal "/audio", audio_samples_path
    assert_equal "/audio/#{@audio_sample.url_slug}", audio_sample_path(@audio_sample)
    assert_equal "/audio/direct_uploads", audio_sample_direct_uploads_path
  end

  test "index is public, newest first, and does not expose coordinates" do
    get audio_samples_url

    assert_response :success
    assert_select "table.audio-sample-list" do
      assert_select "thead th", text: /Title/, count: 1
      assert_select "thead th", text: /Time/, count: 1
      assert_select "thead th", text: /Description/, count: 1
      assert_select "tbody tr.audio-sample-list__row", count: 2
      assert_select "audio[controls]", count: 0
      assert_select "tbody tr:first-child .audio-sample-list__title", text: audio_samples(:two).title
      assert_select "tbody tr:first-child .audio-sample-list__time", text: "2:05"
      assert_select "tbody tr:first-child .audio-sample-list__description", text: audio_samples(:two).description
    end
    assert_select "body", text: /#{Regexp.escape(@audio_sample.latitude.to_s)}/, count: 0
    assert_select "body", text: /#{Regexp.escape(@audio_sample.longitude.to_s)}/, count: 0
  end

  test "index does not show edit links to authenticated users" do
    sign_in_as(users(:one))

    get audio_samples_url

    assert_response :success
    assert_select "a[href=?]", edit_audio_sample_path(@audio_sample), count: 0
  end

  test "show is public and does not expose coordinates" do
    get audio_sample_url(@audio_sample)

    assert_response :success
    assert_select "h1.page-content__title", text: @audio_sample.title
    assert_select "audio.audio-sample__native-player[controls][controlslist=nodownload][preload=none]", count: 1
    assert_select ".audio-player__button", count: 0
    assert_select ".audio-sample__description", text: @audio_sample.description
    assert_select "body", text: /#{Regexp.escape(@audio_sample.latitude.to_s)}/, count: 0
    assert_select "body", text: /#{Regexp.escape(@audio_sample.longitude.to_s)}/, count: 0
  end

  test "show resolves a custom URL slug" do
    get audio_sample_url(@audio_sample.url_slug)

    assert_response :success
    assert_select "h1.page-content__title", text: @audio_sample.title
  end

  test "show returns not found for an unknown URL slug" do
    get audio_sample_url("unknown-recording")

    assert_response :not_found
  end

  test "write actions require authentication" do
    requests = [
      -> { get new_audio_sample_url },
      -> { post audio_samples_url, params: { audio_sample: valid_attributes } },
      -> { get edit_audio_sample_url(@audio_sample) },
      -> { patch audio_sample_url(@audio_sample), params: { audio_sample: valid_attributes } },
      -> { delete audio_sample_url(@audio_sample) }
    ]

    requests.each do |request|
      request.call
      assert_redirected_to new_session_path
    end
  end

  test "authenticated user can create an audio sample" do
    sign_in_as(users(:one))

    assert_difference("AudioSample.count") do
      post audio_samples_url, params: { audio_sample: valid_attributes }
    end
    assert_redirected_to audio_sample_url(AudioSample.last)
    assert_predicate AudioSample.last.audio_file, :attached?
  end

  test "invalid create renders the form" do
    sign_in_as(users(:one))

    assert_no_difference("AudioSample.count") do
      post audio_samples_url, params: { audio_sample: valid_attributes.merge(description: "") }
    end
    assert_response :unprocessable_entity
  end

  test "invalid create preserves a completed direct upload" do
    sign_in_as(users(:one))
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("mp3 data"),
      filename: "sample.mp3",
      content_type: "audio/mpeg"
    )

    post audio_samples_url, params: {
      audio_sample: valid_attributes.merge(description: "", audio_file: blob.signed_id)
    }

    assert_response :unprocessable_entity
    assert_select "input[type=hidden][name='audio_sample[audio_file]'][value=?]", blob.signed_id
  end

  test "authenticated user can open the new and edit forms" do
    sign_in_as(users(:one))

    get new_audio_sample_url
    assert_response :success
    get edit_audio_sample_url(@audio_sample)
    assert_response :success
  end

  test "forms upload MP3 files through the audio direct upload endpoint" do
    sign_in_as(users(:one))

    get new_audio_sample_url

    assert_select "input[name='audio_sample[title]']"
    assert_select "input[name='audio_sample[url_slug]']"
    assert_select "input[type=file][accept='audio/mpeg,.mp3'][data-direct-upload-url=?]", audio_sample_direct_uploads_path
    assert_select "input[type=hidden][name='audio_sample[duration_seconds]']"
  end

  test "authenticated user can update and replace an audio sample" do
    sign_in_as(users(:one))

    replacement = fixture_file_upload("sample.mp3", "audio/mpeg")
    patch audio_sample_url(@audio_sample), params: {
      audio_sample: {
        title: "Evening Birds",
        url_slug: "evening-birds-new",
        description: "Evening birds",
        duration_seconds: 42.5,
        audio_file: replacement
      }
    }

    assert_redirected_to audio_sample_url("evening-birds-new")
    @audio_sample.reload
    assert_equal "Evening Birds", @audio_sample.title
    assert_equal "Evening birds", @audio_sample.description
    assert_equal "sample.mp3", @audio_sample.audio_file.filename.to_s
  end

  test "invalid update does not change the record" do
    sign_in_as(users(:one))

    assert_no_changes -> { @audio_sample.reload.description } do
      patch audio_sample_url(@audio_sample), params: { audio_sample: { description: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "authenticated user can destroy an audio sample" do
    sign_in_as(users(:one))

    assert_difference("AudioSample.count", -1) do
      delete audio_sample_url(@audio_sample)
    end
    assert_redirected_to audio_samples_url
  end

  private

  def valid_attributes
    {
      title: "Rain on the Roof",
      url_slug: "rain-on-the-roof-#{SecureRandom.hex(4)}",
      description: "Rain on the roof",
      duration_seconds: 75.5,
      latitude: 40.7128,
      longitude: -74.0060,
      audio_file: fixture_file_upload("sample.mp3", "audio/mpeg")
    }
  end
end
