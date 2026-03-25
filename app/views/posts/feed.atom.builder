xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "Skye Freeman"
  xml.id blog_url
  xml.link rel: "self", type: "application/atom+xml", href: blog_feed_url(format: :atom)
  xml.link rel: "alternate", type: "text/html", href: blog_url
  xml.updated @posts.first&.published_at&.iso8601 || Time.current.iso8601
  xml.author { xml.name "Skye Freeman" }

  @posts.each do |post|
    xml.entry do
      xml.title post.title
      xml.id post_full_url(post)
      xml.link rel: "alternate", type: "text/html", href: post_full_url(post)
      xml.published post.published_at.iso8601
      xml.updated post.updated_at.iso8601
      xml.content post.body.to_s, type: "html"
    end
  end
end
