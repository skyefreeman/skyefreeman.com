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
end
