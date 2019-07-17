class DomainCount < ActiveRecord::Base
  include Elasticsearch::Model

  def self.update_count(domain_list)
    domain_list.each do |domain|
      domain_count_instance = find_by_domain_name(domain)
        if domain_count_instance.nil?
          domain_count_instance = new(domain_name: domain)
          domain_count_instance.save
        end
      domain_count_instance.increment!(:count)
    end
  end

  def self.return_count_for_domain(domain_query)
    if domain_query.starts_with?('http')
      uri = Addressable:URI.parse(domain_query)
      domain_query = uri.host.nil? ? domain_query : uri.host
    elsif PublicSuffix.valid?(domain_query)
      domain_query = PublicSuffix.parse(domain_query).domain
    end
    self.search(domain_query)
  end
end
