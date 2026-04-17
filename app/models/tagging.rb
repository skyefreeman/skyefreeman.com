class Tagging < ApplicationRecord
  belongs_to :taggable, polymorphic: true
  belongs_to :tag

  validates :taggable_id, uniqueness: { scope: [:taggable_type, :tag_id] }
end
