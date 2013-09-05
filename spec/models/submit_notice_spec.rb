require 'spec_helper'

describe SubmitNotice do
  context "#notice" do
    it "returns a memoized instance" do
      notice = Dmca.new
      Dmca.should_receive(:new).once.
        with(attribute: 'value').and_return(notice)

      submit_notice = SubmitNotice.new(Dmca, attribute: 'value')

      expect(submit_notice.notice).to eq notice
      expect(submit_notice.notice).to eq notice
    end
  end

  context "#errors" do
    it "delegates to #notice" do
      notice = stub_new(Dmca)
      notice.stub(:errors).and_return(:arbitrary)
      submit_notice = SubmitNotice.new(Dmca, {})

      expect(submit_notice.errors).to eq :arbitrary
    end
  end

  context "#submit" do
    it "auto redacts always" do
      notice = stub_new(Dmca)
      notice.should_receive(:auto_redact)

      SubmitNotice.new(Dmca, {}).submit
    end

    it "returns true and marks for review success" do
      notice = stub_new(Dmca)
      notice.stub(:save).and_return(true)
      notice.should_receive(:mark_for_review)

      ret = SubmitNotice.new(Dmca, {}).submit

      expect(ret).to be_true
    end

    it "returns false on failure" do
      notice = stub_new(Dmca)
      notice.stub(:save).and_return(false)

      ret = SubmitNotice.new(Dmca, {}).submit

      expect(ret).to be_false
    end
  end

  context "#submit for a user" do
    it "does nothing if the user has no entity" do
      Dmca.should_receive(:new).with(title: "A title").and_return(null_object)

      SubmitNotice.new(Dmca, title: "A title").submit(User.new)
    end

    it "adds entity attributes when user has an entity" do
      user = build(:user, :with_entity)
      Dmca.should_receive(:new).with(
        title: "A title",
        entity_notice_roles_attributes: [
          { name: 'submitter', entity_id: user.entity.id },
          { name: 'recipient', entity_id: user.entity.id }
        ]
      ).and_return(null_object)

      SubmitNotice.new(Dmca, title: "A title").submit(user)
    end

    it "does not affect other roles" do
      user = build(:user, :with_entity)
      Dmca.should_receive(:new).with(
        entity_notice_roles_attributes: [
          { name: 'sender', entity_attributes: { name: 'Sender' } },
          { name: 'submitter', entity_id: user.entity.id },
          { name: 'recipient', entity_id: user.entity.id }
        ]
      ).and_return(null_object)

      SubmitNotice.new(Dmca, entity_notice_roles_attributes: [
        { name: 'sender', entity_attributes: { name: 'Sender' } }
      ]).submit(user)
    end

    it "does not override an explicitly submitted entity" do
      user = build(:user, :with_entity)
      Dmca.should_receive(:new).with(
        entity_notice_roles_attributes: [
          { name: 'recipient', entity_attributes: { name: 'Recipient' } },
          { name: 'submitter', entity_id: user.entity.id }
        ]
      ).and_return(null_object)

      SubmitNotice.new(Dmca, entity_notice_roles_attributes: [
        { name: 'recipient', entity_attributes: { name: 'Recipient' } }
      ]).submit(user)
    end
  end

  private

  def stub_new(klass)
    klass.new.tap do |instance|
      klass.stub(:new).and_return(instance)
    end
  end

  def null_object(name = "NullObject")
    double(name).as_null_object
  end
end
