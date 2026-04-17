require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  test "is valid with a taggable and tag" do
    tagging = Tagging.new(taggable: posts(:two), tag: tags(:ruby))
    assert tagging.valid?
  end

  test "is invalid when the same tag is applied to the same taggable twice" do
    duplicate = Tagging.new(taggable: posts(:one), tag: tags(:ruby))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:taggable_id], "has already been taken"
  end

  test "requires a taggable" do
    tagging = Tagging.new(taggable: nil, tag: tags(:ruby))
    assert_not tagging.valid?
  end

  test "requires a tag" do
    tagging = Tagging.new(taggable: posts(:one), tag: nil)
    assert_not tagging.valid?
  end

  test "can belong to a note" do
    tagging = Tagging.new(taggable: notes(:two), tag: tags(:ruby))
    assert tagging.valid?
  end

  test "can belong to an idea" do
    tagging = Tagging.new(taggable: ideas(:two), tag: tags(:ruby))
    assert tagging.valid?
  end

  test "can belong to a link" do
    tagging = Tagging.new(taggable: links(:two), tag: tags(:ruby))
    assert tagging.valid?
  end
end
