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

  def post_published_date_links(date)
    month_link = link_to(date.strftime("%B"), posts_by_month_path(year: date.year, month: date.strftime("%m")))
    day_link   = link_to(date.strftime("%d"), posts_by_day_path(year: date.year, month: date.strftime("%m"), day: date.strftime("%d")))
    year_link  = link_to(date.strftime("%Y"), posts_by_year_path(year: date.year))
    safe_join([month_link, " ", day_link, ", ", year_link])
  end

  def post_tag_links(post)
    safe_join(post.tags.map { |tag|
      link_to(tag.name, tag_path(tag.name), class: "post__tag-link")
    }, ", ")
  end
end
