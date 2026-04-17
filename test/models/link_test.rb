require "test_helper"

class LinkTest < ActiveSupport::TestCase
  test "is valid with a url" do
    link = Link.new(url: "https://example.com")
    assert link.valid?
  end

  test "has many tags through taggings" do
    link = links(:one)
    assert_includes link.tags.map(&:name), "ruby"
  end

  test "tag_names= assigns tags from comma-separated string" do
    link = links(:two)
    link.tag_names = "ruby, elixir"
    assert_equal 2, link.tags.length
    assert_includes link.tags.map(&:name), "ruby"
    assert_includes link.tags.map(&:name), "elixir"
  end

  test "tag_names returns comma-separated tag names" do
    link = links(:one)
    assert_includes link.tag_names.split(", "), "ruby"
  end

  test "tag_names= reuses existing tags" do
    link = links(:two)
    link.tag_names = "ruby"
    assert_equal 1, Tag.where(name: "ruby").count
  end

  test "destroying a link destroys its taggings" do
    link = links(:one)
    assert_difference "Tagging.count", -1 do
      link.destroy
    end
  end
end
