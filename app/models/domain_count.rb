class DomainCount < ActiveRecord::Base
	def self.update_count(domain)
		if self.find_by_domain_name(domain).nil?
			self.new(domain_count: domain).save
		end
		self.find_by_domain_name(domain).increment!(:count)
	end
end
