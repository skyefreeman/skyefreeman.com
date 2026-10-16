class Game < ApplicationRecord
  has_one_attached :cover_image
  has_one_attached :linux_package
  has_one_attached :macos_package
  has_one_attached :windows_package

  validates :title, presence: true
  validates :url_slug, uniqueness: true, allow_blank: true
end
