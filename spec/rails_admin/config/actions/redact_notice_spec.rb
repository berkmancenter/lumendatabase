require 'spec_helper'
require 'rails_admin/config/actions/redact_notice'

describe RedactNoticeProc do
  before do
    @object = double("Object", save: false).as_null_object
    @action = double("Action", template_name: '')
    @request = double("Request", get?: false, put?: false)
    @format = double("Format", html: nil, js: nil)
  end

  it "sets the correct redactable fields" do
    instance_eval(&RedactNoticeProc)

    expect(@redactable_fields).to eq Notice::REDACTABLE_FIELDS
  end

  it "sets next requiring review correctly" do
    object.stub(:next_requiring_review).and_return(:not_nil)

    instance_eval(&RedactNoticeProc)

    expect(@next_notice).to eq :not_nil
  end

  context "Handling GET requests" do
    before { request.stub(:get?).and_return(true) }

    it "renders the action template for html" do
      format.stub(:html).and_yield
      action.stub(:template_name).and_return('template_name')
      should_receive(:render).with('template_name')

      instance_eval(&RedactNoticeProc)
    end

    it "renders with layout false for js" do
      format.stub(:js).and_yield
      action.stub(:template_name).and_return('template_name')
      should_receive(:render).with('template_name', layout: false)

      instance_eval(&RedactNoticeProc)
    end
  end

  context "Handling PUT requests" do
    before do
      request.stub(:put?).and_return(true)

      @abstract_model = double("Abstract model", param_key: nil)
      @model_config = double("Model config", with: nil)
      @params = {}
    end

    it "updates the object's attributes" do
      stub_notice_params(
        legal_other: "A",
        legal_other_original: "B",
        review_required: "1"
      )
      object.should_receive(:legal_other=).with("A")
      object.should_receive(:legal_other_original=).with("B")
      object.should_receive(:review_required=).with("1")
      object.should_receive(:save)

      instance_eval(&RedactNoticeProc)
    end

    it "calls handle_save_error on failure" do
      stub_notice_params
      object.stub(:save).and_return(false)
      should_receive(:handle_save_error).with(:edit)

      instance_eval(&RedactNoticeProc)
    end

    context "successful save" do
      before do
        stub_notice_params
        object.stub(:save).and_return(true)
      end

      it "calls redirect_to_on_success" do
        format.stub(:html).and_yield
        should_receive(:redirect_to_on_success)

        instance_eval(&RedactNoticeProc)
      end

      it "redirects to next when appropriate" do
        params[:save_and_next] = true
        next_notice = double("Next notice", id: 1)
        format.stub(:html).and_yield
        object.stub(:next_requiring_review).and_return(next_notice)
        should_receive(:redact_notice_path).and_return(:some_path)
        should_receive(:redirect_to).with(:some_path)

        instance_eval(&RedactNoticeProc)
      end

      it "renders JSON for js requests" do
        object.stub(:id).and_return(1)
        format.stub(:js).and_yield
        config = double("Config", object_label: "Label")
        model_config.should_receive(:with).with(object: object).and_return(config)
        should_receive(:render).with(json: { id: "1", label: "Label" })

        instance_eval(&RedactNoticeProc)
      end
    end

    attr_reader :abstract_model, :model_config, :params

    def stub_notice_params(notice_params = {})
      abstract_model.stub(:param_key).and_return(:notice)
      @params = HashWithIndifferentAccess.new(notice: notice_params)
    end

    def handle_save_error(*)
    end
  end

  attr_reader :object, :action, :request, :format

  def respond_to
    yield(format)
  end
end
