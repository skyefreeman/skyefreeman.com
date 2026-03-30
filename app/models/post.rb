class Post < ApplicationRecord
  has_many :taggings, dependent: :destroy
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
end
