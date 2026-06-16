require 'rails_helper'

describe ApplicationController do
  describe '#after_sign_in_path_for' do
    it 'sends pro enterprise users to their sorted enterprise notices' do
      account = create(:enterprise_account, plan: 'pro')
      user = create(:user, :enterprise, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(
        enterprise_notices_search_index_path(sort_by: 'created_at desc')
      )
    end

    it 'sends a confirmed not-yet-pro enterprise user to settings to choose a plan' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(enterprise_settings_path)
    end

    it 'sends an unconfirmed enterprise user home' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(root_path)
    end
  end
end
