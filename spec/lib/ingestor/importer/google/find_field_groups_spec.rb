require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Google::FindFieldGroups do
  it "finds the correct number of groups" do
    finder = described_class.new(field_group_content)

    expect(finder.find.length).to be 2
  end

  it "splits field groups correctly" do
    finder = described_class.new(field_group_content)

    expect(finder.find).to match_array([
      described_class::FieldGroup.new(0, first_group),
      described_class::FieldGroup.new(1, second_group),
    ])
  end

  it "can find the correct number of field groups" do
    finder = described_class.new(missing_url_content)

    expect(finder.find.length).to eq 23
  end

  def first_group
    %q|field_group_0_work_description: Description 0

field_group_0_copyright_work_url_0:http://copyrighted_0
field_group_0_copyright_work_url_1:http://copyrighted_0_2
field_group_0_infringement_url_0:http://infringing_0
field_group_0_infringement_url_1:http://infringing_0_2|
  end

  def second_group
    %q|field_group_1_work_description: Description 1

field_group_1_copyright_work_url_0:http://copyrighted_1
field_group_1_copyright_work_url_1:http://copyrighted_1_2
field_group_1_infringement_url_0:http://infringing_1
field_group_1_infringement_url_1:http://infringing_1_2|
  end

  def field_group_content
    %Q|
    #{first_group}
    #{second_group}
field_signature:
field_form_submission_time:05/26/2013 PDT
|
  end

  private

  def missing_url_content
    File.read('spec/support/example_files/missing_url_notice_source.txt')
  end
end
