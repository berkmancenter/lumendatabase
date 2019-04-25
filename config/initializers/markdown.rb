renderer = Redcarpet::Render::HTML
extensions = {
  no_intra_emphasis: true,
  autolink: true,
  disable_indented_code_blocks: true
}

# Don't call this Markdown or you'll get loud, frequent warnings about its
# collision with the Markdown constant previously defined inside Redcarpet.
MarkdownParser = Redcarpet::Markdown.new(renderer, extensions)
