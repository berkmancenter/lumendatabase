require 'rails_helper'

RSpec.describe DomainCount, type: :model do
  context 'update domain count' do
    it 'increments the count of a domain that already exists' do
      DomainCount.new(domain_name: 'twitter.com').save
      DomainCount.update_count(['twitter.com'])
      expect(DomainCount.find_by_domain_name('twitter.com').count).to eq(1)
    end

    it 'creates a new domain if the domain is not existant' do
      DomainCount.update_count(['google.com'])
      expect(DomainCount.find_by_domain_name('google.com')).not_to be_nil
    end
  end

  context 'domain count search works fine', type: :model do
    it 'searches for the domain with partial name' do
      DomainCount.new({ domain_name: 'twitter.com', count: 1}).save
      expect(DomainCount.return_count_for_domain('twitter')).to eq(1)
      expect(DomainCount.return_count_for_domain('twitter.com')).to eq(1)
      expect(DomainCount.return_count_for_domain('https://twitter.com')).to eq(1)
      expect(DomainCount.return_count_for_domain('www.twitter.com')).to eq(1)
      expect(DomainCount.return_count_for_domain('https://www.twitter.com')).to eq(1)
    end
  end
end
