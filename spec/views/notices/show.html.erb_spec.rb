require 'spec_helper'

describe 'notices/show.html.erb' do
  it "displays a metadata from a notice" do
    notice = build(:notice, :with_body)
    assign(:notice, notice)

    render

    expect(rendered).to include notice.title
    expect(rendered).to include notice.body
  end

  it "displays the notices file" do
    notice = create(:notice_with_notice_file, content: "File content")
    assign(:notice, notice)

    render

    expect(rendered).to include("File content")
  end

  it "displays a notice with tags" do
    notice = create(:notice, :with_tags)
    assign(:notice, notice)

    render

    within('#tags') do
      expect(page).to have_content("a_tag")
    end
  end
end
