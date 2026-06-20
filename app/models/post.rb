class Post < ApplicationRecord
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_rich_text :body
  has_one_attached :header_attachment
  has_many_attached :body_attachments

  validates :title, presence: true
  validates :url_slug, presence: { message: "is required when publishing" }, if: -> { published_at.present? }

  after_initialize { self.author ||= "Skye Freeman" }

  def tag_names=(names)
    self.tags = names.split(",").map { |name| Tag.where(name: name.strip).first_or_create! }
  end

  def tag_names
    tags.map(&:name).join(", ")
  end

  def excerpt(word_limit = 100)
    plain = body.to_plain_text
    first_paragraph = plain.split(/\n+/).first.to_s.squish
    words = first_paragraph.split
    if words.length > word_limit
      words.first(word_limit).join(" ") + "…"
    else
      first_paragraph
    end
  end
end
