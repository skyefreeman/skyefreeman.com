#!/usr/bin/env ruby
# Imports legacy posts from script/legacy-posts/html/ into the database.
# Run script/preconvert_posts.rb locally first to generate the HTML files.
# - Reads pre-converted HTML body and paired YAML metadata files
# - Creates a Post record with ActionText body for each file
# - Attaches inline <figure> images as body_attachments and rewrites <img src> to blob URLs

require_relative "../config/environment"
require "yaml"

HTML_DIR          = File.expand_path("legacy-posts/html", __dir__)
LEGACY_IMAGES_DIR = File.expand_path("legacy-posts/images", __dir__)

def parse_date(date_str)
  Date.parse(date_str)
rescue ArgumentError, TypeError
  nil
end

# Uploads images referenced in <figure> blocks as body_attachments and rewrites
# their src to the Active Storage blob URL. Returns [updated_html, attachment_count].
def attach_and_rewrite_figures(post, html)
  count = 0
  updated = html.gsub(/src="\/images\/([^"]+)"/) do
    filename   = $1
    local_path = File.join(LEGACY_IMAGES_DIR, filename)

    unless File.exist?(local_path)
      puts "    WARNING: body image not found: #{local_path}"
      next $&
    end

    blob = ActiveStorage::Blob.create_and_upload!(
      io:           File.open(local_path),
      filename:     filename,
      content_type: Marcel::MimeType.for(Pathname.new(local_path))
    )
    post.body_attachments.attach(blob)

    blob_path = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    count += 1
    "src=\"#{blob_path}\""
  end
  [ updated, count ]
end

html_files = Dir.glob("#{HTML_DIR}/*.html").sort
puts "Found #{html_files.size} post(s) to import\n\n"

imported = 0
skipped  = 0

html_files.each do |html_path|
  stem      = File.basename(html_path, ".html")
  meta_path = File.join(HTML_DIR, "#{stem}.yml")

  unless File.exist?(meta_path)
    puts "  SKIP #{stem} — no metadata file"
    skipped += 1
    next
  end

  meta  = YAML.safe_load(File.read(meta_path), permitted_classes: [ Date, Time ]) || {}
  title = meta["title"].to_s.strip

  if title.empty?
    puts "  SKIP #{stem} — no title"
    skipped += 1
    next
  end

  html         = File.read(html_path)
  published_at = parse_date(meta["date"].to_s)

  post = Post.create!(
    title:        title,
    author:       meta["author"] || "Skye Freeman",
    description:  meta["description"],
    published_at: published_at,
    url_slug:     meta["url_slug"].presence
  )

  html, figure_count = attach_and_rewrite_figures(post, html)
  puts "    attached #{figure_count} inline image(s)" if figure_count > 0

  post.body = html
  post.save!

  puts "  ✓ #{title} (#{published_at || 'no date'})"
  imported += 1
end

puts "\nImported #{imported} post(s), skipped #{skipped}."
