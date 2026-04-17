require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "is valid with required attributes" do
    note = Note.new(title: "Hello")
    assert note.valid?
  end

  test "is invalid without a title" do
    note = Note.new(title: "")
    assert_not note.valid?
    assert_includes note.errors[:title], "can't be blank"
  end

  test "has rich text body" do
    note = notes(:one)
    assert_respond_to note, :body
  end

  test "has many tags through taggings" do
    note = notes(:one)
    assert_includes note.tags.map(&:name), "ruby"
  end

  test "tag_names= assigns tags from comma-separated string" do
    note = notes(:two)
    note.tag_names = "ruby, elixir"
    assert_equal 2, note.tags.length
    assert_includes note.tags.map(&:name), "ruby"
    assert_includes note.tags.map(&:name), "elixir"
  end

  test "tag_names returns comma-separated tag names" do
    note = notes(:one)
    assert_includes note.tag_names.split(", "), "ruby"
  end

  test "tag_names= reuses existing tags" do
    note = notes(:two)
    note.tag_names = "ruby"
    assert_equal 1, Tag.where(name: "ruby").count
  end

  test "destroying a note destroys its taggings" do
    note = notes(:one)
    assert_difference "Tagging.count", -1 do
      note.destroy
    end
  end
end
