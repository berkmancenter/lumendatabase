require 'rails_helper'
require 'ingestor'

RSpec.describe Ingestor::Importer::Google::FieldGroupParser do

  it "extracts work descriptions" do
    expect(parser.description).to eq("Artist Name:Rick Astley
Track Name: Flipy The Bear")
  end

  it "extracts copyrighted_urls" do
    expect(parser.copyrighted_urls).to match_array(
      [
        "http://example.com/original_work_url",
        "http://example.com/original_work_url_again"
      ]
    )
  end

  it "extracts infringing_urls" do
    expect(parser.infringing_urls).to match_array(
      [
        "http://infringing.example.com/url_0",
        "http://infringing.example.com/url_1",
      ]
    )
  end

  private

  def parser
    described_class.new(
      double("FieldGroup", key: 0, content: field_group_content)
    )
  end

  def field_group_content
%q|field_group_0_work_description:Artist Name:Rick Astley
Track Name: Flipy The Bear

field_group_0_copyright_work_url_0:http://example.com/original_work_url
field_group_0_copyright_work_url_1:http://example.com/original_work_url_again
field_group_0_infringement_url_0:http://infringing.example.com/url_0
field_group_0_infringement_url_1:http://infringing.example.com/url_1|
  end
end
