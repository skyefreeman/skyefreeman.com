require "test_helper"

class HomeFeedTest < ActionDispatch::IntegrationTest
  setup do
    Post.destroy_all
    Link.destroy_all
    Game.destroy_all

    @post = Post.create!(title: "Published post", url_slug: "published-post",
      body: "An excerpt from the post.", created_at: Time.utc(2025, 1, 1), published_at: Time.utc(2026, 1, 20))
    @link = Link.create!(title: "Interesting link", url: "example.com/article", created_at: Time.utc(2026, 1, 30))
    @game = Game.create!(title: "New game", url_slug: "new-game", description: "A fun game.", created_at: Time.utc(2026, 1, 10))
    @draft = Post.create!(title: "Private draft", created_at: Time.utc(2026, 1, 25))
  end

  test "public home interleaves links posts and games with correct destinations" do
    get root_path
    assert_response :success
    assert_equal [ @link.title, @post.title, @game.title ], titles
    assert_select "#home_link_#{@link.id} a[href='https://example.com/article'][target='_blank'][rel='noopener noreferrer']"
    assert_select "#home_game_#{@game.id} a[href='#{game_by_slug_path(@game.url_slug)}']"
    assert_select "#home_post_#{@post.id} .post-list__excerpt", text: "An excerpt from the post."
    assert_select "#home_game_#{@game.id} .post-list__excerpt", text: @game.description
    assert_select ".post__draft-badge", count: 0
    assert_select "nav[aria-label='More content']", count: 0
  end

  test "link cells render a body only when present" do
    @link.update!(body: "A short description.")

    get root_path
    assert_select "#home_link_#{@link.id} .post-list__excerpt", text: "A short description."

    @link.update!(body: "")
    get links_path
    assert_select "#link_#{@link.id} .post-list__excerpt", count: 0
  end

  test "signed in home includes drafts by creation time" do
    sign_in_as(users(:one))
    get root_path
    assert_equal [ @link.title, @draft.title, @post.title, @game.title ], titles
    assert_select "#home_post_#{@draft.id} .post__draft-badge + time"
  end

  test "home limits the merged feed rather than each type separately" do
    102.times do |index|
      Link.create!(title: "Link #{index}", url: "https://example.com/#{index}", created_at: Time.utc(2026, 2, 1) + index.hours)
    end
    @game.update!(created_at: Time.utc(2026, 3, 1))
    @post.update!(published_at: Time.utc(2026, 3, 2))
    get root_path
    assert_equal [ @post.title, @game.title ] + (4..101).to_a.reverse.map { |index| "Link #{index}" }, titles
  end

  test "home handles untitled links and games without slugs" do
    @link.update!(title: nil)
    @game.update!(url_slug: nil)
    get root_path
    assert_select "#home_link_#{@link.id} a", text: @link.url
    assert_select "#home_game_#{@game.id} a[href='#{game_path(@game)}']"
  end

  test "home renders with no content" do
    Post.destroy_all
    Link.destroy_all
    Game.destroy_all
    get root_path
    assert_response :success
    assert_select ".post-list__item", count: 0
  end

  test "home displays a type badge first in the date row including drafts" do
    sign_in_as(users(:one))
    get root_path
    { @post => [ "post", "Blog post" ], @draft => [ "post", "Blog post" ],
      @link => [ "link", "Link" ], @game => [ "game", "Game" ] }.each do |entry, (type, label)|
      assert_select "#home_#{type}_#{entry.id} .post-list__date > .home-feed__badge--#{type}:first-child", text: label
    end
  end

  test "link listing does not display home type badges" do
    get links_path
    assert_select ".home-feed__badge", count: 0
  end

  test "game cartridge appears immediately beneath the title only when attached" do
    get root_path
    assert_select "#home_game_#{@game.id} img", count: 0

    png = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a5n8AAAAASUVORK5CYII=")
    @game.cover_image.attach(io: StringIO.new(png), filename: "cartridge.png", content_type: "image/png")
    get root_path
    assert_select "#home_game_#{@game.id} .post-list__title + img.game__cover-image[alt='New game cartridge'][loading=lazy]"
    assert_select "#home_game_#{@game.id} a.home-feed__content-link[href='#{game_by_slug_path(@game.url_slug)}']" do
      assert_select "h1", text: @game.title
      assert_select "img.game__cover-image"
      assert_select ".post-list__date, .post-list__excerpt", count: 0
    end
  end

  test "post title and excerpt share a link while metadata stays outside" do
    get root_path
    path = post_by_date_slug_path(year: 2026, month: "01", day: "19", slug: @post.url_slug)
    assert_select "#home_post_#{@post.id} a.home-feed__content-link[href='#{path}']" do
      assert_select "h1", text: @post.title
      assert_select ".post-list__excerpt", text: "An excerpt from the post."
      assert_select ".post-list__date", count: 0
    end
  end

  private

  def titles
    css_select(".post-list__title").map { |element| element.text.strip }
  end
end
