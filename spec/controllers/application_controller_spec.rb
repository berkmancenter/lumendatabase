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

    it 'sends inactive enterprise users to the account status page' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(enterprise_status_path)
    end
  end
end
