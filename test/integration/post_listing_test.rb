require "test_helper"

class PostListingTest < ActionDispatch::IntegrationTest
  setup do
    Link.destroy_all
    Game.destroy_all
    @published = posts(:one)
    @published.update!(created_at: Time.utc(2025, 1, 1), published_at: Time.utc(2026, 1, 15))
    @draft = posts(:two)
    @draft.update!(created_at: Time.utc(2026, 1, 10))
    @new_draft = Post.create!(title: "Newest draft", created_at: Time.utc(2026, 1, 20))
  end

  test "home and blog interleave drafts by creation and published posts by publication" do
    sign_in_as(users(:one))

    [ root_path, blog_path ].each do |path|
      get path
      assert_response :success
      assert_equal [ @new_draft.title, @published.title, @draft.title ],
        css_select(".post-list__title").map { |element| element.text.strip }, path
      assert_select ".post__draft-badge", text: "DRAFT", count: 2
    end
  end

  test "public listings still hide drafts and draft badges" do
    [ root_path, blog_path ].each do |path|
      get path
      assert_equal [ @published.title ], css_select(".post-list__title").map { |element| element.text.strip }, path
      assert_select ".post__draft-badge", count: 0
    end
  end

  test "draft listings show creation date and time beside the badge" do
    sign_in_as(users(:one))
    @draft.update!(created_at: Time.zone.local(2026, 1, 10, 14, 35))

    [ root_path, blog_path ].each do |path|
      get path
      assert_select ".post__draft-badge + time[datetime='2026-01-10T14:35:00-05:00']",
        text: "January 10, 2026 at 2:35 PM"
    end
  end

  test "home limits the combined chronological list to one hundred posts" do
    sign_in_as(users(:one))
    100.times do |index|
      Post.create!(title: "Recent post #{index}", url_slug: "recent-#{index}", published_at: Time.utc(2026, 2, 1) + index.days)
    end

    get root_path
    assert_equal (0..99).to_a.reverse.map { |index| "Recent post #{index}" },
      css_select(".post-list__title").map { |element| element.text.strip }
  end

  test "draft detail uses the same badge" do
    sign_in_as(users(:one))
    get post_path(@draft)
    assert_select ".post__meta .post__draft-badge", text: "DRAFT"
  end
end
