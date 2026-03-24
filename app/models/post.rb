class Post < ApplicationRecord
  has_rich_text :body
  has_one_attached :header_attachment
  has_many_attached :body_attachments

  validates :title, presence: true
  validates :url_slug, presence: { message: "is required when publishing" }, if: -> { published_at.present? }

  after_initialize { self.author ||= "Skye Freeman" }
end
