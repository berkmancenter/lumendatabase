class AddVerificationTokenToEnterpriseDomains < ActiveRecord::Migration[7.2]
  def up
    add_column :enterprise_domains, :verification_token, :string

    EnterpriseDomain.reset_column_information
    EnterpriseDomain.find_each do |enterprise_domain|
      enterprise_domain.update_columns(verification_token: SecureRandom.hex(16))
    end

    change_column_null :enterprise_domains, :verification_token, false
    add_index :enterprise_domains, :verification_token, unique: true
  end

  def down
    remove_index :enterprise_domains, :verification_token
    remove_column :enterprise_domains, :verification_token
  end
end
