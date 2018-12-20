require 'spec_helper'

describe NoticeSubmissionFinalizer, type: :model do
  it 'updates a notice with provided parameters' do
    notice = build(:dmca)
    notice.save
    notice.reload
    orig_works_count = notice.works.count

    NoticeSubmissionFinalizer.new(
      notice, works_attributes: works_attributes
    ).finalize

    notice.reload

    expect(notice.works.count).to eq orig_works_count + 1
    expect(
      work_matches(notice.works.first) || work_matches(notice.works.second)
    ).to be true
  end

  it 'copies id to submission_id' do
    notice = build(:dmca)
    notice.save
    notice.reload

    NoticeSubmissionFinalizer.new(
      notice, works_attributes: works_attributes
    ).finalize

    notice.reload
    expect(notice.submission_id).to eq notice.id
  end

  private

  def works_attributes
    [{
      description: 'The Avengers',
      infringing_urls_attributes: [
        { url: 'http://youtube.com/bad_url_1' },
        { url: 'http://youtube.com/bad_url_2' },
        { url: 'http://youtube.com/bad_url_3' }
      ]
    }]
  end

  # The works_attributes will not be *equal*, because the submitted notice
  # works will contain ids and timestamps. We'll just check the part we set.
  def work_matches(work)
    same_description = (work.description == works_attributes[0][:description])
    same_urls = (infringing_urls(work) ==
                 works_attributes[0][:infringing_urls_attributes])
    same_description && same_urls
  end

  def infringing_urls(work)
    retval = []
    work.infringing_urls.each do |url|
      retval << { url: url.url_original }
    end
    retval
  end
end
