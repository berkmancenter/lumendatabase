require 'param_flattener'

# This performs final updates to a Notice instance that has been created, but
# not yet supplied with all its attributes. The goal here is to be able to
# move slow parts of the notice creation process outside the request/response
# cycle.
class NoticeSubmissionFinalizer
  include ParamFlattener

  delegate :errors, to: :notice

  def initialize(notice, parameters)
    @notice = notice
    @parameters = parameters
  end

  def finalize
    parameters[:submission_id] = notice.id
    notice.works.delete(NoticeSubmissionInitializer::PLACEHOLDER_WORKS)
    fix_concatenated_urls(:infringing_urls_attributes)
    fix_concatenated_urls(:copyrighted_urls_attributes)
    notice.update_attributes(parameters)
  end

  private

  attr_accessor :parameters
  attr_accessor :notice

  # Sometimes we get submissions which, instead of containing a single URL,
  # contain a long list of URLs, concatenated. We don't necessarily persist
  # these to the db as they may exceed the 1.kilobyte allowed length. When we
  # see this problem, we should instead create a CopyrightedUrl instance for
  # each URL, as this is surely the original intent.
  def fix_concatenated_urls(attr)
    flatten_param(parameters[:works_attributes]).each do |work_hash|
      next unless work_hash[attr].present?

      new_hashes = []

      flatten_param(work_hash[attr]).each do |url_hash|
        next unless url_hash[:url].scan('/http').present?

        split_urls = conservative_split(url_hash[:url])

        # Overwrite the current URL with one of the split-apart URLs. Then
        # add the rest of the split-apart URLs to a list for safekeeping.
        url_hash[:url] = split_urls.pop()
        split_urls.map { |url| new_hashes << { url: url } }
      end

      # Now that we know all the URLs which needed to be un-concatenated,
      # update the work hash. We're doing that here because we don't want to
      # modify it while looping over its contents!
      work_hash[attr] += new_hashes.uniq if new_hashes.present?
    end
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
