require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "is valid with required attributes" do
    post = Post.new(title: "Hello", author: "Skye")
    assert post.valid?
  end

  test "is invalid without a title" do
    post = Post.new(title: "")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "has rich text body" do
    post = posts(:one)
    assert_respond_to post, :body
  end

  test "has one attached header_attachment" do
    post = posts(:one)
    assert_respond_to post, :header_attachment
  end

  test "has many attached body_attachments" do
    post = posts(:one)
    assert_respond_to post, :body_attachments
  end

  test "deleted_at is nil by default" do
    post = Post.new(title: "Hello", author: "Skye")
    assert_nil post.deleted_at
  end

  test "is valid as a draft without url_slug" do
    post = Post.new(title: "Hello", author: "Skye")
    assert post.valid?
  end

  test "is invalid when published without url_slug" do
    post = Post.new(title: "Hello", author: "Skye", published_at: Time.current)
    assert_not post.valid?
    assert_includes post.errors[:url_slug], "is required when publishing"
  end

  test "is valid when published with url_slug" do
    post = Post.new(title: "Hello", author: "Skye", url_slug: "hello", published_at: Time.current)
    assert post.valid?
  end
end
