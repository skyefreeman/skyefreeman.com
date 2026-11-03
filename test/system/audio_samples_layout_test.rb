require "test_helper"

class AudioSamplesLayoutTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1200, 900 ]

  test "audio samples use aligned compact rows contained on mobile" do
    visit audio_samples_path
    assert_selector ".audio-sample-list__row", count: 2
    assert_selector ".audio-sample-list thead th", count: 3

    desktop = table_layout
    assert_in_delta desktop["headers"][0], desktop["cells"][0], 1
    assert_in_delta desktop["headers"][1], desktop["cells"][1], 1
    assert_in_delta desktop["headers"][2], desktop["cells"][2], 1
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
        return {
          headers: headers.map(element => element.getBoundingClientRect().left),
          cells: cells.map(element => element.getBoundingClientRect().left),
          rowHeight: row.getBoundingClientRect().height
        };
      })()
    JS
  end
end
