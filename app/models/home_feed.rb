class HomeFeed
  def self.entries(include_drafts: false, limit: 30)
    posts = Post.chronological
    posts = posts.where.not(published_at: nil) unless include_drafts

    entries = posts.includes(:tags, :rich_text_body).limit(limit).to_a +
      Link.order(created_at: :desc, id: :desc).includes(:tags).limit(limit).to_a +
      Game.order(created_at: :desc, id: :desc).with_attached_cover_image.limit(limit).to_a

    entries.sort_by { |entry|
      time = entry.is_a?(Post) ? entry.published_at || entry.created_at : entry.created_at
      [ -time.to_r, entry.class.name, -entry.id ]
    }.first(limit)
  end
end
