# This performs final updates to a Notice instance that has been created, but
# not yet supplied with all its attributes. The goal here is to be able to
# move slow parts of the notice creation process outside the request/response
# cycle.
class NoticeSubmissionFinalizer
  delegate :errors, to: :notice

  def initialize(notice, parameters)
    @notice = notice
    @parameters = parameters
  end

  def finalize
    parameters[:submission_id] = notice.id
    notice.works.delete(NoticeSubmissionInitializer::PLACEHOLDER_WORKS)
    notice.update_attributes(parameters)
    DomainCount.update_count(give_domains_from_urls(notice.infringing_urls))
  end

  private

  attr_reader :parameters
  attr_accessor :notice

  def give_domains_from_urls(infringing_urls_list)
    infringing_urls_list.map{ |x| extract_domain(x.url) }.uniq
  end

  def extract_domain(url)
    url.start_with? "http" ? Addressable::URI.parse(url).domain : PublicSuffix.domain(url)
  end
  
end
