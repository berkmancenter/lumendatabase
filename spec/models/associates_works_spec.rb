require 'spec_helper'

describe AssociatesWorks do
  it 'does nothing if there are no valid works' do
    associater = described_class.new(nil, double(), double())

    Work.should_not_receive(:new)
    InfringingUrl.should_not_receive(:new)
    associater.associate
  end


  it 'initializes a Work properly' do
    Work.should_receive(:find_or_initialize_by_url).with(
      'http://www.example.com/original_work.pdf',
      description: 'a heartbreaking work of staggering genius',
      kind: 'book'
    ).and_return(Work.new)

    with_valid_associater do |associater, notice, submission|
      associater.associate
    end
  end

  it 'initializes InfringingUrls properly' do
    InfringingUrl.should_receive(:find_or_initialize_by_url).with(
      'http://www.example.com/infringing_url'
    ).and_return(InfringingUrl.new)

    with_valid_associater do |associater, notice, submission|
      associater.associate
    end

  end

  def with_valid_associater
    works_params = [
      example_work
    ]
    notice = Notice.new
    submission = Submission.new
    associater = described_class.new(works_params, notice, submission)
    yield associater, notice, submission
  end

  def example_infringing_urls
    [
      'http://www.example.com/infringing_url',
    ]
  end

  def example_work
    {
      url: 'http://www.example.com/original_work.pdf',
      description: 'a heartbreaking work of staggering genius',
      kind: 'book',
      infringing_urls: example_infringing_urls
    }
  end

end
