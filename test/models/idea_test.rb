require "test_helper"

class IdeaTest < ActiveSupport::TestCase
  test "is valid with required attributes" do
    idea = Idea.new(title: "A great idea")
    assert idea.valid?
  end

  test "is invalid without a title" do
    idea = Idea.new(title: "")
    assert_not idea.valid?
    assert_includes idea.errors[:title], "can't be blank"
  end

  test "is valid without an output_url" do
    idea = Idea.new(title: "A great idea")
    assert idea.valid?
  end

  test "output_url is nil by default" do
    idea = ideas(:two)
    assert_nil idea.output_url
  end

  test "has many tags through taggings" do
    idea = ideas(:one)
    assert_includes idea.tags.map(&:name), "rails"
  end

  test "tag_names= assigns tags from comma-separated string" do
    idea = ideas(:two)
    idea.tag_names = "ruby, elixir"
    assert_equal 2, idea.tags.length
    assert_includes idea.tags.map(&:name), "ruby"
    assert_includes idea.tags.map(&:name), "elixir"
  end

  test "tag_names returns comma-separated tag names" do
    idea = ideas(:one)
    assert_includes idea.tag_names.split(", "), "rails"
  end

  test "tag_names= reuses existing tags" do
    idea = ideas(:two)
    idea.tag_names = "ruby"
    assert_equal 1, Tag.where(name: "ruby").count
  end

  test "destroying an idea destroys its taggings" do
    idea = ideas(:one)
    assert_difference "Tagging.count", -1 do
      idea.destroy
    end
  end
end
