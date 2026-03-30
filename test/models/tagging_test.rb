require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  test "is valid with a post and tag" do
    post = posts(:two)
    tag = tags(:ruby)
    tagging = Tagging.new(post: post, tag: tag)
    assert tagging.valid?
  end

  test "is invalid when the same tag is applied to the same post twice" do
    post = posts(:one)
    tag = tags(:ruby)
    duplicate = Tagging.new(post: post, tag: tag)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:post_id], "has already been taken"
  end

  test "requires a post" do
    tagging = Tagging.new(post: nil, tag: tags(:ruby))
    assert_not tagging.valid?
  end

  test "requires a tag" do
    tagging = Tagging.new(post: posts(:one), tag: nil)
    assert_not tagging.valid?
  end
end
