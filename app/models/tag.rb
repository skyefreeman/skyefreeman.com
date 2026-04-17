class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings, source: :taggable, source_type: "Post"
  has_many :notes, through: :taggings, source: :taggable, source_type: "Note"
  has_many :ideas, through: :taggings, source: :taggable, source_type: "Idea"
  has_many :links, through: :taggings, source: :taggable, source_type: "Link"

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
