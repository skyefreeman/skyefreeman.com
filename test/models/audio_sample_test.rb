require "test_helper"

class AudioSampleTest < ActiveSupport::TestCase
  setup do
    @audio_sample = AudioSample.new(
      title: "Morning in the Park",
      url_slug: "morning-in-the-park-2",
      description: "Morning birds",
      latitude: 40.7128,
      longitude: -74.0060,
      duration_seconds: 61.25
    )
    attach_mp3(@audio_sample)
  end

  test "is valid with an MP3 and optional coordinates" do
    assert_predicate @audio_sample, :valid?

    @audio_sample.latitude = nil
    @audio_sample.longitude = nil
    assert_predicate @audio_sample, :valid?
  end

  test "requires a title, description, duration, and audio file" do
    @audio_sample.title = nil
    @audio_sample.description = nil
    @audio_sample.duration_seconds = nil
    @audio_sample.audio_file.detach

    assert_not @audio_sample.valid?
    assert_equal [ "can't be blank" ], @audio_sample.errors[:title]
    assert_equal [ "can't be blank" ], @audio_sample.errors[:description]
    assert_equal [ "can't be blank" ], @audio_sample.errors[:duration_seconds]
    assert_equal [ "must be attached" ], @audio_sample.errors[:audio_file]
  end

  test "uses a unique optional URL slug as its route parameter" do
    @audio_sample.id = 123
    @audio_sample.url_slug = "  "
    assert_predicate @audio_sample, :valid?
    assert_nil @audio_sample.url_slug
    assert_equal "123", @audio_sample.to_param

    @audio_sample.url_slug = audio_samples(:one).url_slug
    assert_not @audio_sample.valid?
    assert_equal [ "has already been taken" ], @audio_sample.errors[:url_slug]

    @audio_sample.url_slug = "custom-recording"
    assert_equal "custom-recording", @audio_sample.to_param
  end

  test "requires a positive duration" do
    @audio_sample.duration_seconds = 0

    assert_not @audio_sample.valid?
    assert_equal [ "must be greater than 0" ], @audio_sample.errors[:duration_seconds]
  end

  test "validates coordinate ranges" do
    { latitude: [ -90.0001, 90.0001 ], longitude: [ -180.0001, 180.0001 ] }.each do |attribute, invalid_values|
      invalid_values.each do |value|
        @audio_sample.public_send("#{attribute}=", value)
        assert_not @audio_sample.valid?, "expected #{attribute}=#{value} to be invalid"
      end
      @audio_sample.public_send("#{attribute}=", nil)
    end
  end

  test "accepts boundary coordinates" do
    [ [ -90, -180 ], [ 90, 180 ] ].each do |latitude, longitude|
      @audio_sample.latitude = latitude
      @audio_sample.longitude = longitude
      assert_predicate @audio_sample, :valid?
    end
  end

  test "only accepts MP3 attachments" do
    @audio_sample.audio_file.attach(io: StringIO.new("wave"), filename: "sample.wav", content_type: "audio/wav")

    assert_not @audio_sample.valid?
    assert_equal [ "must be an MP3" ], @audio_sample.errors[:audio_file]
  end

  test "accepts common MP3 content types" do
    %w[audio/mp3 audio/x-mp3].each do |content_type|
      @audio_sample.audio_file.attach(io: StringIO.new("audio"), filename: "sample.mp3", content_type: content_type)
      assert_predicate @audio_sample, :valid?
    end
  end

  test "limits attachments to twenty mebibytes" do
    @audio_sample.audio_file.attach(
      io: StringIO.new("0" * (20.megabytes + 1)),
      filename: "large.mp3",
      content_type: "audio/mpeg"
    )

    assert_not @audio_sample.valid?
    assert_equal [ "must be 20 MiB or smaller" ], @audio_sample.errors[:audio_file]
  end

  private

  def attach_mp3(audio_sample)
    audio_sample.audio_file.attach(
      io: StringIO.new("mp3 data"),
      filename: "sample.mp3",
      content_type: "audio/mpeg"
    )
  end
end
