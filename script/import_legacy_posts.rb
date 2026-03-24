#!/usr/bin/env ruby
# Imports legacy posts from script/legacy-posts/ into the database.
# - Parses YAML front matter for metadata
# - Converts markdown body to HTML via pandoc
# - Creates a Post record with ActionText body for each file

require_relative "../config/environment"
require "yaml"
require "open3"

LEGACY_POSTS_DIR = File.expand_path("legacy-posts", __dir__)

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
  post.body = html
  post.save!

  puts "  ✓ #{title} (#{published_at || 'no date'})"
  imported += 1
end

puts "\nImported #{imported} post(s), skipped #{skipped}."
