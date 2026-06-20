class Game < ApplicationRecord
  has_one_attached :cover_image

  validates :title, presence: true
  validates :url_slug, uniqueness: true, allow_blank: true
end
