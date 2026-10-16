require "test_helper"

class GamesLayoutTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1200, 900 ]

  test "game cards use two desktop columns and one mobile column" do
    visit games_path
    assert_selector ".game-list__item", count: 2

    desktop = card_layout
    assert_in_delta desktop[0]["top"], desktop[1]["top"], 1
    assert_operator desktop[1]["left"], :>, desktop[0]["left"]
    assert_in_delta desktop[0]["width"], desktop[1]["width"], 1
    assert_equal "rgb(243, 243, 243)", desktop[0]["background"]

    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride",
      width: 390, height: 844, deviceScaleFactor: 1, mobile: true)
    mobile = card_layout
    assert_in_delta mobile[0]["left"], mobile[1]["left"], 1
    assert_operator mobile[1]["top"], :>=, mobile[0]["bottom"]
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")

    click_link games(:one).title
    assert_selector "h1", text: games(:one).title
  end

  private

  def card_layout
    page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.game-list__item')).map(card => {
        const rect = card.getBoundingClientRect();
        return { top: rect.top, bottom: rect.bottom, left: rect.left,
          width: rect.width, background: getComputedStyle(card).backgroundColor };
      })
    JS
  end
end
