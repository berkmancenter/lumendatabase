require 'spec_helper'

describe MarkdownParser do
  it "renders markdown to html" do
    html = MarkdownParser.render("some *nice* markdown")

    expect(html).to eq "<p>some <em>nice</em> markdown</p>\n"
  end

  it "reuses the same RedCarpet::Markdown instance" do
    expect(Redcarpet::Markdown).not_to receive(:new)

    MarkdownParser.render("markdown")
    MarkdownParser.render("markdown")
  end
end
