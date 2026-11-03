require "test_helper"

class AudioSamplesHelperTest < ActionView::TestCase
  test "formats durations with hours only when needed" do
    assert_equal "0:09", format_audio_duration(9.8)
    assert_equal "1:01", format_audio_duration(61.25)
    assert_equal "1:01:01", format_audio_duration(3661.9)
  end
end
