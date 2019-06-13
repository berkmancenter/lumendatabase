require 'rails_helper'

RSpec.describe DomainCount, type: :model do
  context 'update domain count' do
		it 'increments the count of a domain that already exists' do
			DomainCount.new(domain_name: 'twitter.com').save
			DomainCount.update_count('twitter.com')
			expect(DomainCount.find_by_domain_name('twitter.com').count).to eq(1)
		end

		it 'creates a new domain if the domain is not existant' do
			DomainCount.update_count('google.com')
			expect(DomainCount.find_by_domain_name('google.com')).not_to be_nil
		end
  end
end
