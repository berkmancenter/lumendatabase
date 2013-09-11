require 'spec_helper'

describe BlogEntry do
  context "automatic validations" do
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:title) }
  end

  it { should belong_to(:user) }
  it { should have_many(:blog_entry_categorizations).dependent(:destroy) }
  it { should have_many(:categories).through(:blog_entry_categorizations) }
  it { should ensure_inclusion_of(:image).in_array BlogEntry.valid_images }

  it_behaves_like "an object with a recent scope"

  context ".valid_images" do
    it "returns the names found in app/assets/images/blog/imagery" do
      expected_images = %w(
        clouds default desert autumn
        lightning overcast rain snow
        storm sunny sunset tornado
      )

      expect(BlogEntry.valid_images).to match_array(expected_images)
    end
  end

  context "#content_html" do
    it "returns the post's content as html" do
      blog_entry = BlogEntry.new(content: "Some *markdown* content")

      html = blog_entry.content_html

      expect(html).to eq "<p>Some <em>markdown</em> content</p>\n"
    end
  end
end
