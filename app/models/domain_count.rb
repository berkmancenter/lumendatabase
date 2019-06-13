class DomainCount < ActiveRecord::Base
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
end
