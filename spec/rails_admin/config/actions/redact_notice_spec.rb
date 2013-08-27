require 'spec_helper'
require 'rails_admin/config/actions/redact_notice'

describe "RedactNoticeProc" do
  include RailsAdminActionContext

  before { setup_action_context }

  context "Handling GET requests" do
    before { request.stub(:get?).and_return(true) }

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

    it "delegates to the PutResponder" do
      responder = double("Put responder")
      responder.should_receive(:handle).with(params)
      PutResponder.should_receive(:new).
        with(self, @abstract_model, @object).and_return(responder)

      instance_eval(&RedactNoticeProc)
    end

    context "PutResponder#handler" do
      it "updates the objects attributes" do
        stub_notice_params(
          body: "A",
          body_original: "B",
          review_required: "1"
        )
        @object.should_receive(:body=).with("A")
        @object.should_receive(:body_original=).with("B")
        @object.should_receive(:review_required=).with("1")
        @object.should_receive(:save)

        put_responder.handle(params)
      end

      it "updates the object's attributes" do
        stub_notice_params(
          body: "A",
          body_original: "B",
          review_required: "1"
        )
        @object.should_receive(:body=).with("A")
        @object.should_receive(:body_original=).with("B")
        @object.should_receive(:review_required=).with("1")
        @object.should_receive(:save)

        put_responder.handle(params)
      end

      it "calls handle_save_error on failure" do
        stub_notice_params
        @object.stub(:save).and_return(false)
        should_receive(:handle_save_error).with(:redact_notice)

        put_responder.handle(params)
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

          put_responder.handle(params)
        end

        it "redirects to next when appropriate" do
          params[:save_and_next] = true
          params[:next_notices] = %w( 1 2 3 )
          format.stub(:html).and_yield
          should_receive(:redact_notice_path).
            with(@abstract_model, '1', next_notices: %w( 2 3 )).
            and_return(:some_path)
          should_receive(:redirect_to).with(:some_path)

          put_responder.handle(params)
        end

        it "renders JSON for js requests" do
          format.stub(:js).and_yield
          @object.stub(:id).and_return(1)
          should_receive(:render).with(json: { id: "1", label: "Redact notice" })

          put_responder.handle(params)
        end
      end
    end

    def stub_notice_params(notice_params = {})
      @abstract_model.stub(:param_key).and_return(:notice)
      params[:notice] = notice_params
    end

    def handle_save_error(*)
    end
  end

  context "Handling POST requests" do
    before { request.stub(:post?).and_return(true) }

    it "delegates to the PostResponder" do
      responder = double("Post responder")
      responder.should_receive(:handle).with(params)
      PostResponder.should_receive(:new).
        with(self, @abstract_model, @object).and_return(responder)

      instance_eval(&RedactNoticeProc)
    end

    context "PostResponder#handle" do
      it "redacts this and all next notices" do
        params[:selected_text] = "Sensitive thing"
        params[:next_notices]  = %w( 2 3 4 )
        redactor = expect_new(RedactsNotices, [
          expect_new(RedactsNotices::RedactsContent, "Sensitive thing")
        ])
        redactor.should_receive(:redact_all).with([@object.id, 2, 3, 4])
        should_receive(:redact_notice_path).
          with(@abstract_model, 1, next_notices: %w( 2 3 4 )).
          and_return(:some_path)
        should_receive(:redirect_to).with(:some_path)

        post_responder.handle(params)
      end

      it "redacts only this notice if there are no next notices" do
        params[:selected_text] = "Sensitive thing"
        redactor = stub_new(RedactsNotices, [
          stub_new(RedactsNotices::RedactsContent, "Sensitive thing")
        ])
        redactor.should_receive(:redact_all).with([@object.id])
        should_receive(:redact_notice_path).
          with(@abstract_model, 1, next_notices: nil).and_return(:some_path)
        should_receive(:redirect_to).with(:some_path)

        post_responder.handle(params)
      end
    end
  end

  def put_responder
    PutResponder.new(self, @abstract_model, @object)
  end

  def post_responder
    PostResponder.new(self, @abstract_model, @object)
  end

  def stub_new(klass, *args)
    klass.new(*args).tap do |instance|
      klass.stub(:new).and_return(instance)
    end
  end

  def expect_new(klass, *args)
    klass.new(*args).tap do |instance|
      klass.should_receive(:new).with(*args).and_return(instance)
    end
  end
end
