require "test_helper"

class AudioSamplesLayoutTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1200, 900 ]

  test "audio samples use aligned compact rows contained on mobile" do
    audio_sample = audio_samples(:two)
    audio_sample.audio_file.attach(
      io: StringIO.new("mp3 data"),
      filename: "sample.mp3",
      content_type: "audio/mpeg"
    )
    audio_sample.update!(description: "A long field recording description " * 30)
    visit audio_samples_path
    assert_selector ".audio-sample-list__row", count: 2
    assert_selector ".audio-sample-list thead th", count: 3

    desktop = table_layout
    assert_in_delta desktop["headers"][0], desktop["cells"][0], 1
    assert_in_delta desktop["headers"][1], desktop["cells"][1], 1
    assert_in_delta desktop["headers"][2], desktop["cells"][2], 1
    assert_in_delta desktop["buttonCenterX"], desktop["iconCenterX"], 0.5
    assert_in_delta desktop["buttonCenterY"], desktop["iconCenterY"], 0.5
    assert_in_delta 6, desktop["playPathCenterX"], 0.01
    assert_in_delta 6, desktop["playPathCenterY"], 0.01
    assert_in_delta 6, desktop["pausePathCenterX"], 0.01
    assert_in_delta 6, desktop["pausePathCenterY"], 0.01
    assert_operator desktop["descriptionScrollWidth"], :>, desktop["descriptionClientWidth"]
    assert_equal 0, desktop["descriptionScrollbarHeight"]
    assert_operator desktop["rowHeight"], :<, 64

    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride",
      width: 390, height: 844, deviceScaleFactor: 1, mobile: true)
    mobile = page.evaluate_script(<<~JS)
      (() => {
        const wrapper = document.querySelector('.audio-sample-list__wrapper');
        return { scrollWidth: wrapper.scrollWidth, clientWidth: wrapper.clientWidth };
      })()
    JS
    assert_operator mobile["scrollWidth"], :>, mobile["clientWidth"]
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  end

  private

  def table_layout
    page.evaluate_script(<<~JS)
      (() => {
        const headers = Array.from(document.querySelectorAll('.audio-sample-list thead th'));
        const row = document.querySelector('.audio-sample-list__row');
        const cells = Array.from(row.querySelectorAll('td'));
        const button = row.querySelector('.audio-player__button').getBoundingClientRect();
        const icon = row.querySelector('.audio-player__icon').getBoundingClientRect();
        const playPath = row.querySelector('.audio-player__icon-play').getBBox();
        const pausePath = row.querySelector('.audio-player__icon-pause').getBBox();
        const description = row.querySelector('.audio-sample-list__description-content');
        return {
          headers: headers.map(element => element.getBoundingClientRect().left),
          cells: cells.map(element => element.getBoundingClientRect().left),
          buttonCenterX: button.left + button.width / 2,
          buttonCenterY: button.top + button.height / 2,
          iconCenterX: icon.left + icon.width / 2,
          iconCenterY: icon.top + icon.height / 2,
          playPathCenterX: playPath.x + playPath.width / 2,
          playPathCenterY: playPath.y + playPath.height / 2,
          pausePathCenterX: pausePath.x + pausePath.width / 2,
          pausePathCenterY: pausePath.y + pausePath.height / 2,
          descriptionScrollWidth: description.scrollWidth,
          descriptionClientWidth: description.clientWidth,
          descriptionScrollbarHeight: description.offsetHeight - description.clientHeight,
          rowHeight: row.getBoundingClientRect().height
        };
      })()
    JS
  end
end
