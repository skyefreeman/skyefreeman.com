#!/usr/bin/env ruby
# Migrates legacy blog posts from the Common Lisp site into script/legacy-posts/
# - Parses metadata from blog.lisp
# - Matches entries to markdown files by filepath stem
# - For HTML-only posts, extracts post-content block and converts to markdown via pandoc
# - Prepends YAML front matter and copies to script/legacy-posts/
# - Reports unmatched posts at the end

require "fileutils"

BLOG_LISP    = File.expand_path("~/dev/skyefreeman-web/src/blog.lisp")
MARKDOWN_DIR = File.expand_path("~/dev/skyefreeman-web/views/posts/markdown")
HTML_DIR     = File.expand_path("~/dev/skyefreeman-web/views/posts")
OUTPUT_DIR   = File.expand_path("legacy-posts", __dir__)

# Parse all make-instance 'post blocks from blog.lisp
def parse_posts(lisp_source)
  lisp_source.scan(/make-instance 'post(.*?)(?=make-instance 'post|\z)/m).map do |match|
    block = match[0]
    {
      title:       extract_field(block, "title"),
      description: extract_field(block, "description"),
      author:      extract_field(block, "author"),
      date:        extract_field(block, "date"),
      filepath:    extract_field(block, "filepath"),
    }
  end
end

def extract_field(block, field)
  match = block.match(/:#{field}\s+#?P?"((?:[^"\\]|\\.)*)"/m)
  match ? match[1].gsub('\\"', '"').strip : ""
end

# Derive the stem from the :filepath value
# e.g. #P"/generated/foo-bar.html" -> "foo-bar"
#      #P"a-fresh-start.html"      -> "a-fresh-start"
def filepath_stem(filepath_str)
  File.basename(filepath_str, ".html")
end

def front_matter(post)
  <<~YAML
    ---
    layout: post
    title: "#{post[:title].gsub('"', '\\"')}"
    date: "#{post[:date]}"
    author: #{post[:author]}
    description: "#{post[:description].gsub('"', '\\"')}"
    ---
  YAML
end

# Extract content between {% block post-content %} and {% endblock %}
def extract_html_content(html_source)
  match = html_source.match(/\{%\s*block post-content\s*%\}(.*?)\{%\s*endblock\s*%\}/m)
  match ? match[1].strip : nil
end

BOLD_CLASSES   = %w[font-bold font-semibold].freeze
ITALIC_CLASSES = %w[font-italic italic].freeze

def element_classes(tag)
  tag.match(/class="([^"]*)"/)&.then { |m| m[1].split } || []
end

# Before pandoc: replace class-based bold/italic styling on inline elements
# with semantic <strong>/<em> so pandoc produces correct markdown.
# Handles both plain spans and anchor tags (with or without href).
def normalize_html_styles(html)
  # Match full self-contained inline elements: <tag ...>content</tag>
  html.gsub(/<(a|span)(\s[^>]*)?>.*?<\/\1>/m) do |match|
    tag_open  = match.match(/<(a|span)(\s[^>]*)?>/)
    tag_name  = tag_open[1]
    attrs_str = tag_open[2] || ""
    classes   = element_classes(match)
    bold      = classes.any? { |c| BOLD_CLASSES.include?(c) }
    italic    = classes.any? { |c| ITALIC_CLASSES.include?(c) }

    # Extract inner content
    inner = match.sub(/<(a|span)[^>]*>/, "").sub(/<\/(a|span)>$/, "")

    # Rebuild: keep href if present, strip class
    href  = attrs_str.match(/href="([^"]*)"/)&.then { |m| m[1] }
    clean_attrs = href ? " href=\"#{href}\"" : ""
    rebuilt = "<#{tag_name}#{clean_attrs}>#{inner}</#{tag_name}>"

    rebuilt = "<strong>#{rebuilt}</strong>" if bold
    rebuilt = "<em>#{rebuilt}</em>"         if italic
    rebuilt
  end
end

def html_to_markdown(html)
  prepared = normalize_html_styles(html)
  md = IO.popen(["pandoc", "-f", "html", "-t", "markdown"], "r+") do |io|
    io.write(prepared)
    io.close_write
    io.read
  end
  clean_markdown(md)
end

def clean_markdown(md)
  md
    .gsub(/\s*\{[^}]*\}/, "")  # strip {#anchor .class} attributes from headings and elsewhere
    .gsub("\\'", "'")           # unescape \' -> '
end

# Search for an HTML file by stem in HTML_DIR and HTML_DIR/generated/
def find_html_file(stem)
  [
    File.join(HTML_DIR, "#{stem}.html"),
    File.join(HTML_DIR, "generated", "#{stem}.html")
  ].find { |path| File.exist?(path) }
end

lisp_source = File.read(BLOG_LISP)
posts = parse_posts(lisp_source)

markdown_files = Dir.glob("#{MARKDOWN_DIR}/*.{md,markdown}").map do |path|
  ext = File.extname(path)
  [File.basename(path, ext), path]
end.to_h

FileUtils.mkdir_p(OUTPUT_DIR)

matched   = []
unmatched = []

posts.each do |post|
  stem = filepath_stem(post[:filepath])
  next if stem.empty?

  if (source_path = markdown_files[stem])
    dest_path = File.join(OUTPUT_DIR, File.basename(source_path))
    content   = File.read(source_path)
    body = content.start_with?("---") ? content : front_matter(post) + content
    File.write(dest_path, body)
    matched << { stem: stem, source: :markdown }

  elsif (html_path = find_html_file(stem))
    html_source = File.read(html_path)
    html_content = extract_html_content(html_source)

    if html_content
      markdown_content = html_to_markdown(html_content)
      dest_path = File.join(OUTPUT_DIR, "#{stem}.md")
      File.write(dest_path, front_matter(post) + markdown_content)
      matched << { stem: stem, source: :html }
    else
      unmatched << { title: post[:title], stem: stem, reason: "could not extract post-content block" }
    end

  else
    unmatched << { title: post[:title], stem: stem, reason: "no source file found" }
  end
end

puts "Migrated #{matched.size} post(s):"
matched.each { |m| puts "  ✓ #{m[:stem]} (#{m[:source]})" }

puts "\nCould not migrate #{unmatched.size} post(s):"
unmatched.each { |p| puts "  ✗ #{p[:title]} (#{p[:stem]}): #{p[:reason]}" }
