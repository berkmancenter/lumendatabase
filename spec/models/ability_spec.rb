require 'spec_helper'

# non-admin in the sense that they cannot access /admin at all
shared_examples 'a non-admin' do
  it "cannot access admin" do
    expect(subject.can? :read, notice).to be_falsey
    expect(subject.can? :access, :rails_admin).to be_falsey
    expect(subject.can? :read, :dashboard).to be_falsey
  end
end

# admin in the sense that they can access /admin at all
shared_examples 'an admin' do
  it "can access admin" do
    expect(subject.can? :read, notice).to be true
    expect(subject.can? :access, :rails_admin).to be true
    expect(subject.can? :read, :dashboard).to be true
  end
end

shared_examples 'a notice editor' do
  it "can edit notices" do
    expect(subject.can? :edit, notice).to be true
  end

  it "can redact notices" do
    expect(subject.can? :redact_notice, notice).to be true
    expect(subject.can? :redact_queue, notice).to be true
  end

  it "cannot edit other site data" do
    expect(subject.can? :edit, topic).to be_falsey
    expect(subject.can? :edit, user).to be_falsey
    expect(subject.can? :edit, role).to be_falsey
  end
end

shared_examples 'a user that can\'t generate new notice permanent token urls' do
  it "can't generate new notice permanent token urls" do
    expect(subject.can? :generate_permanent_notice_token_urls, Notice).to be false
  end
end

shared_examples 'a user that can generate new notice permanent token urls' do
  it "can't generate new notice permanent token urls" do
    expect(subject.can? :generate_permanent_notice_token_urls, Notice).to be true
  end
end

describe Ability do
  context "a role-less user" do
    subject { Ability.new(build(:user)) }

    it_behaves_like 'a non-admin'
    it_behaves_like 'a user that can\'t generate new notice permanent token urls'

    it "cannot submit to the API" do
      expect(subject.can? :submit, Notice).to be_falsey
    end
  end

  context "a notice viewer" do
    subject { Ability.new(build(:user, :notice_viewer)) }

    it_behaves_like 'a non-admin'
    it_behaves_like 'a user that can\'t generate new notice permanent token urls'

    it "can see full notice urls" do
      expect(subject.can? :view_full_version, Notice).to be true
    end
  end

  context "a notice viewer with the can_generate_permanent_notice_token_urls setting on" do
    subject { Ability.new(build(:user, :notice_viewer, can_generate_permanent_notice_token_urls: true)) }

    it_behaves_like 'a user that can generate new notice permanent token urls'
  end

  context "a submitter" do
    subject { Ability.new(build(:user, :submitter)) }

    it_behaves_like 'a non-admin'
    it_behaves_like 'a user that can\'t generate new notice permanent token urls'

    it "can submit to the API" do
      expect(subject.can? :submit, Notice).to be true
    end
  end

  context "a redactor" do
    subject { Ability.new(build(:user, :redactor)) }

    it_behaves_like 'an admin'
    it_behaves_like 'a notice editor'
    it_behaves_like 'a user that can\'t generate new notice permanent token urls'

    it "cannot publish" do
      expect(subject.can? :publish, notice).to be_falsey
    end

    it "cannot rescind" do
      expect(subject.can? :rescind, notice).to be_falsey
    end
  end

  context "a publisher" do
    subject { Ability.new(build(:user, :publisher)) }

    it_behaves_like 'an admin'
    it_behaves_like 'a notice editor'
    it_behaves_like 'a user that can\'t generate new notice permanent token urls'

    it "can publish" do
      expect(subject.can? :publish, notice).to be true
    end

    it "cannot rescind" do
      expect(subject.can? :rescind, notice).to be_falsey
    end
  end

  context "a researcher" do
    subject { Ability.new(build(:user, :researcher)) }

    it_behaves_like 'a user that can\'t generate new notice permanent token urls'
  end

  context "a researcher with the can_generate_permanent_notice_token_urls setting on" do
    subject { Ability.new(build(:user, :researcher, can_generate_permanent_notice_token_urls: true)) }

    it_behaves_like 'a user that can generate new notice permanent token urls'
  end

  context "an admin" do
    subject { Ability.new(build(:user, :admin)) }

    it_behaves_like 'an admin'
    it_behaves_like 'a user that can generate new notice permanent token urls'

    it "can redact and publish" do
      expect(subject.can? :redact_notice, notice).to be true
      expect(subject.can? :redact_queue, notice).to be true
      expect(subject.can? :publish, notice).to be true
    end

    it "can edit site data" do
      expect(subject.can? :edit, notice).to be true
      expect(subject.can? :edit, topic).to be true
    end

    it "can rescind" do
      expect(subject.can? :rescind, notice).to be true
    end

    it "cannot edit users or role" do
      expect(subject.can? :edit, user).to be_falsey
      expect(subject.can? :edit, role).to be_falsey
    end
  end

  context "a super admin" do
    subject { Ability.new(build(:user, :super_admin)) }

    it_behaves_like 'an admin'
    it_behaves_like 'a user that can generate new notice permanent token urls'

    it "can do everything" do
      expect(subject.can? :manage, notice).to be true
      expect(subject.can? :manage, topic).to be true
      expect(subject.can? :manage, user).to be true
      expect(subject.can? :manage, role).to be true
    end
  end

  private

  def notice;     build(:dmca) end
  def topic;   build(:topic) end
  def user;       build(:user) end
  def role;       build(:role) end
end
