require 'spec_helper'

describe User, type: :model do
  it { is_expected.to belong_to(:entity).optional }
  it { is_expected.to have_and_belong_to_many :roles }
  it { is_expected.to have_and_belong_to_many :full_notice_only_researchers_entities }

  context "#role?" do
    it "returns true when the user has the given role" do
      user = create(:user, roles: [Role.redactor, Role.publisher])

      expect(user.role?(Role.redactor)).to eq true
      expect(user.role?(Role.publisher)).to eq true
    end

    it "returns false when the user does not have the given role" do
      user = create(:user, roles: [Role.redactor, Role.publisher])

      expect(user.role?(Role.admin)).not_to eq true
      expect(user.role?(Role.super_admin)).not_to eq true
    end
  end

  describe '#active_enterprise_account' do
    let(:account) { create(:enterprise_account, plan: 'pro') }

    it 'returns the account for a confirmed enterprise user on the pro plan' do
      user = create(:user, :enterprise, enterprise_account: account)

      expect(user.active_enterprise_account).to eq(account)
    end

    it 'returns nil until the user has confirmed their email' do
      user = create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: account)

      expect(user.active_enterprise_account).to be_nil
    end

    it 'returns nil when the account is not pro' do
      inactive = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, enterprise_account: inactive)

      expect(user.active_enterprise_account).to be_nil
    end
  end

  describe '#confirmed_enterprise_user?' do
    it 'is true for a confirmed user on an approved account, even before pro' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, enterprise_account: account)

      expect(user.confirmed_enterprise_user?).to be true
    end

    it 'is false until the email is confirmed' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: account)

      expect(user.confirmed_enterprise_user?).to be false
    end

    it 'is false when the account is not approved' do
      account = create(:enterprise_account, :pre_registration)
      user = create(:user, :enterprise, enterprise_account: account)

      expect(user.confirmed_enterprise_user?).to be false
    end
  end

  describe '#confirm_enterprise_email!' do
    it 'records the confirmation time and burns the single-use token' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: account)

      user.confirm_enterprise_email!

      expect(user.enterprise_email_confirmed?).to be true
      expect(user.enterprise_email_confirmation_token).to be_nil
    end
  end
end
