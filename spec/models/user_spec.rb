require 'spec_helper'

describe User, type: :model do
  it { is_expected.to have_and_belong_to_many :roles }

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
end
