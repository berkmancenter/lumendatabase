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

  it 'increases the count of domains involved in the notice' do
    notice = build(:dmca)
    notice.save
    
    counter_map = {}
    distinct_domains = infringing_urls_attributes.map { 
      |x| x[:url].start_with?("http") ? Addressable::URI.parse(x[:url]).domain : PublicSuffix.domain(x[:url]) 
    }.uniq
    distinct_domains.each do |domain|
      counter_map[domain] = return_count(DomainCount.find_by_domain_name(domain))
    end

    NoticeSubmissionFinalizer.new(
      notice, works_attributes: works_attributes
    ).finalize

    distinct_domains.each do |domain|
      expect(return_count(DomainCount.find_by_domain_name(domain)) - counter_map[domain]).to eq(1)
    end
  end

  it 'handles large url attributes list efficiently' do
    notice = create(:dmca)
    NoticeSubmissionFinalizer.new(
      notice, works_attributes: works_attributes(1000)
    ).finalize
  end

  it 'handles large values efficiently' do
    expect(Notice.convert_to_int(3.49477e+09)).to eq(3494770000)
    expect(Notice.convert_to_int(4.55453e+07)).to eq(45545300)
    expect(Notice.convert_to_int(500)).to eq(500)
  end
  
  private

  def works_attributes(number_of_urls = 3)
    [{
      description: 'The Avengers',
      infringing_urls_attributes: infringing_urls_attributes(number_of_urls)
    }]
  end

  def infringing_urls_attributes(number_of_urls = 3)
    url_list = []
    for i in 1..number_of_urls + 1
      url_list.push({ url: 'http://youtube.com/bad_url_' + i.to_s })
    end
    url_list
  end

  # The works_attributes will not be *equal*, because the submitted notice
  # works will contain ids and timestamps. We'll just check the part we set.
  def work_matches(work)
    same_description = (work.description == works_attributes[0][:description])

    work_urls = work.infringing_urls.map { |x| x[:url_original] }
    same_urls = infringing_urls_attributes.all? do |url|
      work_urls.include? url[:url]
    end
    test_bijection = (work_urls.length ==
                      infringing_urls_attributes.length)
    test_bijection && same_description && same_urls
  end

  def infringing_urls(work)
    retval = []
    work.infringing_urls.each do |url|
      retval << { url: url.url_original }
    end
    retval
  end

  def return_count(domain_instance)
    domain_instance.nil? ? 0 : domain_instance.count
  end
end
