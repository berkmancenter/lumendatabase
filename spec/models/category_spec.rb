require 'spec_helper'

describe Category do
  it { should validate_presence_of :name }
  it { should have_many(:categorizations).dependent(:destroy) }
  it { should have_many(:notices).through(:categorizations) }
  it { should have_and_belong_to_many :relevant_questions }

  context "#description_html" do
    it "converts #description from markdown" do
      category = build(:category, description: "Some *sweet* markdown")

      html = category.description_html

      expect(html).to eq "<p>Some <em>sweet</em> markdown</p>\n"
    end
  end
end
