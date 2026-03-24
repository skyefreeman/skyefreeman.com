class Post < ApplicationRecord
  has_rich_text :body
  has_one_attached :header_attachment
  has_many_attached :body_attachments

  validates :title, presence: true

  after_initialize { self.author ||= "Skye Freeman" }
end
