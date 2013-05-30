renderer = Redcarpet::Render::HTML
extensions = {
  no_intra_emphasis: true,
  autolink: true,
  disable_indented_code_blocks: true
}

Markdown = Redcarpet::Markdown.new(renderer, extensions)
