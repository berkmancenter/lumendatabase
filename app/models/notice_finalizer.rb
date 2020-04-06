# NoticeFinalizer takes an existing Notice instance and parameters representing
# the works that should be associated with it. It then performs the association.
# This lets us move this potentially slow operation out of the request/response
# loop.
class NoticeFinalizer
  def initialize(notice, works)
    @notice = notice
    @works = works
  end

  def finalize
    fix_concatenated_urls
    notice.works << works
    notice.works.delete(NoticesController::PLACEHOLDER_WORKS)
    notice.save
  end

  private
  attr_accessor :works, :notice

  def fix_concatenated_urls
    return unless works.present?
    works.each do |work|
      work.copyrighted_urls << fixed_urls(work, :copyrighted_urls)
      work.infringing_urls << fixed_urls(work, :infringing_urls)
    end
  end

  def fixed_urls(work, url_type)
    new_urls = []
    work.send(url_type).each do |url_obj|
      next unless url_obj[:url].scan('/http').present?

      split_urls = conservative_split(url_obj[:url])
      # Overwrite the current URL with one of the split-apart URLs. Then
      # add the rest of the split-apart URLs to a list for safekeeping.
      url_obj[:url] = split_urls.pop()
      split_urls_as_hashes = split_urls.map { |url| { url: url } }
      new_urls << work.send(url_type).build(split_urls_as_hashes)
    end
    new_urls
  end

  # We can't just split on 'http', because doing so will result in strings
  # which no longer contain it. We need to look at the pairs of 'http' and
  # $the_rest_of_the_URL which split produces and then mash them back together.
  def conservative_split(s)
    b = []
    s.split(/(http)/).reject { |x| x.blank? }.each_slice(2) { |s| b << s.join }
    b
  end
end
