class Idea < ApplicationRecord
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  validates :title, presence: true

  def tag_names=(names)
    self.tags = names.split(",").map { |name| Tag.where(name: name.strip).first_or_create! }
  end

  def tag_names
    tags.map(&:name).join(", ")
  end
end
