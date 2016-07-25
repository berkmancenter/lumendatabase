require 'spec_helper'

describe BlogEntry, type: :model do
  context "automatic validations" do
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:title) }
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:blog_entry_topic_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:topics).through(:blog_entry_topic_assignments) }
  it { is_expected.to validate_inclusion_of(:image).in_array BlogEntry.valid_images }

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

  context ".published" do
    it "returns only published blog entries in order" do
      create_list(:blog_entry, 2)
      create_list(:blog_entry, 2, published_at: 1.day.from_now)
      create_list(:blog_entry, 2, published_at: 1.hour.from_now)
      newer = create(:blog_entry, published_at: 1.day.ago)
      older = create(:blog_entry, published_at: 2.days.ago)

      expect(BlogEntry.published).to eq [newer, older]
    end
  end

  context ".archived" do
    it "returns only archived blog entries in order" do
      create_list(:blog_entry, 2)
      create_list(:blog_entry, 2, archive: true, published_at: 1.day.from_now)
      create_list(:blog_entry, 2, archive: true, published_at: 1.hour.from_now)
      newer = create(:blog_entry, archive: true, published_at: 1.day.ago)
      older = create(:blog_entry, archive: true, published_at: 2.days.ago)

      expect(BlogEntry.archived).to eq [newer, older]
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
