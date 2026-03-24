#!/usr/bin/env ruby
# Run locally before deploying. Converts markdown bodies in script/legacy-posts/
# to HTML via pandoc and writes them to script/legacy-posts/html/<stem>.html.
# The YAML front matter is preserved in a paired .yml file for the import script.

require "yaml"
require "open3"
require "fileutils"

LEGACY_POSTS_DIR = File.expand_path("legacy-posts", __dir__)
HTML_OUT_DIR     = File.expand_path("legacy-posts/html", __dir__)

def parse_front_matter(raw)
  match = raw.match(/\A---\n(.*?)\n---\n(.*)\z/m)
  return [{}, raw] unless match
  meta = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
  [meta, match[2]]
end

def markdown_to_html(markdown)
  html, err, status = Open3.capture3("pandoc", "-f", "markdown", "-t", "html", stdin_data: markdown)
  raise "pandoc failed: #{err}" unless status.success?
  html
end

FileUtils.mkdir_p(HTML_OUT_DIR)

files = Dir.glob("#{LEGACY_POSTS_DIR}/*.{md,markdown}").sort
puts "Converting #{files.size} file(s)...\n\n"

converted = 0
skipped   = 0

files.each do |path|
  raw        = File.read(path)
  meta, body = parse_front_matter(raw)
  title      = meta["title"].to_s.strip

  if title.empty?
    puts "  SKIP #{File.basename(path)} — no title"
    skipped += 1
    next
  end

  stem     = File.basename(path, File.extname(path))
  html     = markdown_to_html(body)

  File.write(File.join(HTML_OUT_DIR, "#{stem}.html"), html)
  File.write(File.join(HTML_OUT_DIR, "#{stem}.yml"), meta.to_yaml)

  puts "  ✓ #{stem}"
  converted += 1
end

puts "\nConverted #{converted} file(s), skipped #{skipped}."
puts "Output written to #{HTML_OUT_DIR}"
