require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "is valid with a name" do
    tag = Tag.new(name: "elixir")
    assert tag.valid?
  end

  test "is invalid without a name" do
    tag = Tag.new(name: "")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "is invalid with a duplicate name (case-insensitive)" do
    Tag.create!(name: "Elixir")
    duplicate = Tag.new(name: "elixir")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "has many posts through taggings" do
    tag = tags(:ruby)
    assert_includes tag.posts, posts(:one)
  end

  test "has many notes through taggings" do
    tag = tags(:ruby)
    assert_includes tag.notes, notes(:one)
  end

  test "has many ideas through taggings" do
    tag = tags(:rails)
    assert_includes tag.ideas, ideas(:one)
  end

  test "has many links through taggings" do
    tag = tags(:ruby)
    assert_includes tag.links, links(:one)
  end

  test "destroying a tag destroys its taggings" do
    tag = tags(:ruby)
    assert_difference "Tagging.count", -3 do
      tag.destroy
    end
  end
end
