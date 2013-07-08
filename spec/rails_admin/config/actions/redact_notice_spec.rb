require 'spec_helper'
require 'rails_admin/config/actions/redact_notice'

describe RedactNoticeProc do
  include RailsAdminActionContext

  before { setup_action_context }

  it "sets the correct redactable fields" do
    instance_eval(&RedactNoticeProc)

    expect(@redactable_fields).to eq Notice::REDACTABLE_FIELDS
  end

  it "does not set next notice path if the param's not present" do
    instance_eval(&RedactNoticeProc)

    expect(@next_notice_path).to be_nil
  end

  it "sets next notice path when param is present" do
    params[:next_notices] = %w( 1 2 3 )
    should_receive(:redact_notice_path).
      with(@abstract_model, '1', next_notices: %w( 2 3 )).
      and_return(:some_path)

    instance_eval(&RedactNoticeProc)

    expect(@next_notice_path).to eq :some_path
  end

  context "Handling GET requests" do
    before { request.stub(:get?).and_return(true) }

    it "renders the action template for html" do
      format.stub(:html).and_yield
      @action.stub(:template_name).and_return('template_name')
      should_receive(:render).with('template_name')

      instance_eval(&RedactNoticeProc)
    end

    it "renders with layout false for js" do
      format.stub(:js).and_yield
      @action.stub(:template_name).and_return('template_name')
      should_receive(:render).with('template_name', layout: false)

      instance_eval(&RedactNoticeProc)
    end
  end

  context "Handling PUT requests" do
    before { request.stub(:put?).and_return(true) }

    it "updates the object's attributes" do
      stub_notice_params(
        legal_other: "A",
        legal_other_original: "B",
        review_required: "1"
      )
      @object.should_receive(:legal_other=).with("A")
      @object.should_receive(:legal_other_original=).with("B")
      @object.should_receive(:review_required=).with("1")
      @object.should_receive(:save)

      instance_eval(&RedactNoticeProc)
    end

    it "calls handle_save_error on failure" do
      stub_notice_params
      @object.stub(:save).and_return(false)
      should_receive(:handle_save_error).with(:redact_notice)

      instance_eval(&RedactNoticeProc)
    end

    context "successful save" do
      before do
        stub_notice_params
        @object.stub(:save).and_return(true)
      end

      it "redirects to the queue path" do
        format.stub(:html).and_yield
        should_receive(:redact_queue_path).
          with(@abstract_model).and_return(:some_path)
        should_receive(:redirect_to).with(:some_path)

        instance_eval(&RedactNoticeProc)
      end

      it "redirects to next when appropriate" do
        params[:save_and_next] = true
        params[:next_notices] = %w( 1 2 3 )
        format.stub(:html).and_yield
        should_receive(:redact_notice_path).
          with(@abstract_model, '1', next_notices: %w( 2 3 )).
          and_return(:some_path)
        should_receive(:redirect_to).with(:some_path)

        instance_eval(&RedactNoticeProc)
      end

      it "renders JSON for js requests" do
        format.stub(:js).and_yield
        @object.stub(:id).and_return(1)
        mock_model_config(object_label: "Label")
        should_receive(:render).with(json: { id: "1", label: "Label" })

        instance_eval(&RedactNoticeProc)
      end

      def mock_model_config(attrs)
        config = double("Config", attrs)
        @model_config.stub(:with).and_return(config)
      end
    end

    def stub_notice_params(notice_params = {})
      @abstract_model.stub(:param_key).and_return(:notice)
      params[:notice] = notice_params
    end

    def handle_save_error(*)
    end
  end
end
