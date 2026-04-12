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
end
