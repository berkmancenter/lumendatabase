require 'spec_helper'

describe SubmitNotice do
  it "instantiates the model class given" do
    Dmca.should_receive(:new).with(attribute: 'value')

    SubmitNotice.new(Dmca, attribute: 'value')
  end

  context "#notice" do
    it "returns the instantiated instance" do
      notice = stub_new(Dmca)
      submit_notice = SubmitNotice.new(Dmca, {})

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

  private

  def stub_new(klass)
    klass.new.tap do |instance|
      klass.stub(:new).and_return(instance)
    end
  end
end
