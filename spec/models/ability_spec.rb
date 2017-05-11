require 'spec_helper'

# non-admin in the sense that they cannot access /admin at all
shared_examples 'a non-admin' do
  it "cannot access admin" do
    expect(subject.can? :read, notice).to be_falsey
    expect(subject.can? :access, :rails_admin).to be_falsey
    expect(subject.can? :dashboard, nil).to be_falsey
  end
end

# admin in the sense that they can access /admin at all
shared_examples 'an admin' do
  it "can access admin" do
    expect(subject.can? :read, notice).to be true
    expect(subject.can? :access, :rails_admin).to be true
    expect(subject.can? :dashboard, nil).to be true
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
    expect(subject.can? :edit, blog_entry).to be_falsey
    expect(subject.can? :edit, user).to be_falsey
    expect(subject.can? :edit, role).to be_falsey
  end
end

describe Ability do
  context "a role-less user" do
    subject { Ability.new(build(:user)) }

    it_behaves_like 'a non-admin'

    it "cannot submit to the API" do
      expect(subject.can? :submit, Notice).to be_falsey
    end
  end

  context "a submitter" do
    subject { Ability.new(build(:user, :submitter)) }

    it_behaves_like 'a non-admin'

    it "can submit to the API" do
      expect(subject.can? :submit, Notice).to be true
    end
  end

  context "a redactor" do
    subject { Ability.new(build(:user, :redactor)) }

    it_behaves_like 'an admin'
    it_behaves_like 'a notice editor'

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

    it "can publish" do
      expect(subject.can? :publish, notice).to be true
    end

    it "cannot rescind" do
      expect(subject.can? :rescind, notice).to be_falsey
    end
  end

  context "an admin" do
    subject { Ability.new(build(:user, :admin)) }

    it_behaves_like 'an admin'

    it "can redact and publish" do
      expect(subject.can? :redact_notice, notice).to be true
      expect(subject.can? :redact_queue, notice).to be true
      expect(subject.can? :publish, notice).to be true
    end

    it "can edit site data" do
      expect(subject.can? :edit, notice).to be true
      expect(subject.can? :edit, topic).to be true
      expect(subject.can? :edit, blog_entry).to be true
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

    it "can do everything" do
      expect(subject.can? :manage, notice).to be true
      expect(subject.can? :manage, topic).to be true
      expect(subject.can? :manage, blog_entry).to be true
      expect(subject.can? :manage, user).to be true
      expect(subject.can? :manage, role).to be true
    end
  end

  private

  def notice;     build(:dmca) end
  def topic;   build(:topic) end
  def blog_entry; build(:blog_entry) end
  def user;       build(:user) end
  def role;       build(:role) end
end
