require 'spec_helper'

describe User, type: :model do
  it { is_expected.to have_and_belong_to_many :roles }

  context "#has_role?" do
    it "returns true when the user has the given role" do
      user = create(:user, roles: [Role.redactor, Role.publisher])

      expect(user).to have_role(Role.redactor)
      expect(user).to have_role(Role.publisher)
    end

    it "returns false when the user does not have the given role" do
      user = create(:user, roles: [Role.redactor, Role.publisher])

      expect(user).not_to have_role(Role.admin)
      expect(user).not_to have_role(Role.super_admin)
    end
  end
end
