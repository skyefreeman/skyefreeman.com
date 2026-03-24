#!/usr/bin/env ruby
# Imports legacy posts from script/legacy-posts/ into the database.
# - Parses YAML front matter for metadata
# - Converts markdown body to HTML via pandoc
# - Creates a Post record with ActionText body for each file
# - Attaches inline <figure> images as body_attachments and rewrites <img src> to blob URLs

require_relative "../config/environment"
require "yaml"
require "open3"

LEGACY_POSTS_DIR  = File.expand_path("legacy-posts", __dir__)
LEGACY_IMAGES_DIR = File.expand_path("legacy-posts/images", __dir__)

def markdown_to_html(markdown)
  html, err, status = Open3.capture3("pandoc", "-f", "markdown", "-t", "html", stdin_data: markdown)
  raise "pandoc failed: #{err}" unless status.success?
  html
end

def parse_front_matter(raw)
  match = raw.match(/\A---\n(.*?)\n---\n(.*)\z/m)
  return [{}, raw] unless match
  meta = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
  body = match[2]
  [meta, body]
end

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

    url_opts = Rails.application.config.action_mailer.default_url_options || {}
    blob_url = Rails.application.routes.url_helpers.rails_blob_url(blob, **url_opts)
    count += 1
    "src=\"#{blob_url}\""
  end
  [updated, count]
end

files = Dir.glob("#{LEGACY_POSTS_DIR}/*.{md,markdown}").sort
puts "Found #{files.size} post(s) to import\n\n"

imported = 0
skipped  = 0

files.each do |path|
  raw          = File.read(path)
  meta, body   = parse_front_matter(raw)
  title        = meta["title"].to_s.strip

  if title.empty?
    puts "  SKIP #{File.basename(path)} — no title"
    skipped += 1
    next
  end

  html         = markdown_to_html(body)
  published_at = parse_date(meta["date"].to_s)

  post = Post.create!(
    title:        title,
    author:       meta["author"] || "Skye Freeman",
    description:  meta["description"],
    published_at: published_at
  )

  # Rewrite figure blocks and attach inline images
  html, figure_count = attach_and_rewrite_figures(post, html)
  puts "    attached #{figure_count} inline image(s)" if figure_count > 0

  post.body = html
  post.save!

  puts "  ✓ #{title} (#{published_at || 'no date'})"
  imported += 1
end

puts "\nImported #{imported} post(s), skipped #{skipped}."
