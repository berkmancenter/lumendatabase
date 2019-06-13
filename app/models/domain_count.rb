class DomainCount < ActiveRecord::Base
	def self.update_count(domain)
		if find_by_domain_name(domain).nil?
			new(domain_name: domain).save
		end
		find_by_domain_name(domain).increment!(:count)
	end
end
