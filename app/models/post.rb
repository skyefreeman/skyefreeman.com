class Post < ApplicationRecord
  has_rich_text :body
  has_one_attached :header_attachment
  has_many_attached :body_attachments

  validates :title, presence: true

  after_initialize { self.author ||= "Skye Freeman" }

  def date_url_slug
    return nil unless published_at && url_slug.present?
    "#{published_at.strftime("%Y/%m/%d")}/#{url_slug}"
  end
end
