module PostsHelper
  def post_url_path(post)
    return post_path(post) unless post.published_at && post.url_slug.present?

    date = post.published_at
    post_by_date_slug_path(year: date.year, month: date.strftime("%m"), day: date.strftime("%d"), slug: post.url_slug)
  end
end
