module PostsHelper
  def post_url_path(post)
    return post_path(post) unless post.published_at && post.url_slug.present?

    date = post.published_at
    post_by_date_slug_path(year: date.year, month: date.strftime("%m"), day: date.strftime("%d"), slug: post.url_slug)
  end

  def post_full_url(post)
    return post_url(post) unless post.published_at && post.url_slug.present?

    date = post.published_at
    post_by_date_slug_url(year: date.year, month: date.strftime("%m"), day: date.strftime("%d"), slug: post.url_slug)
  end

  def post_og_image_url(post)
    return unless post.header_attachment.attached?

    url_for(post.header_attachment)
  end
end
