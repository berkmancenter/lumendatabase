require 'spec_helper'
require 'rails_admin/config/actions/redact_queue'

describe RedactQueueProc do
  include RailsAdminActionContext

  before { setup_action_context }

  it "fills the user's queue and assigns @objects from it" do
    user = User.new
    self.current_user = user
    notices = double("Notices")
    queue = Redaction::Queue.new(user)
    queue.stub(:notices).and_return(notices)
    queue.should_receive(:fill)
    Redaction::Queue.should_receive(:new).with(user).and_return(queue)

    instance_eval(&RedactQueueProc)

    expect(@objects).to eq notices
  end

  context "rendering" do
    before do
      queue = Redaction::Queue.new(nil)
      queue.stub(:notices).and_return([])
      Redaction::Queue.stub(:new).and_return(queue)
      Redaction::Queue.stub(:fill)
    end

    it "renders the action template for html" do
      format.stub(:html).and_yield
      @action.stub(:template_name).and_return('template_name')
      should_receive(:render).with('template_name')

      instance_eval(&RedactQueueProc)
    end

    it "renders with layout false for js" do
      format.stub(:js).and_yield
      @action.stub(:template_name).and_return('template_name')
      should_receive(:render).with('template_name', layout: false)

      instance_eval(&RedactQueueProc)
    end
  end

  context "POST request" do
    it "redirects to redact notice with the proper parameters" do
      request.stub(:post?).and_return(true)
      params[:selected] = %w( 1 3 5 9 )
      redact_path = double("Redact path")
      should_receive(:redact_notice_path).
        with(@abstract_model, '1', next_notices: %w( 3 5 9 )).
        and_return(redact_path)
      should_receive(:redirect_to).with(redact_path)
      should_not_receive(:respond_to)

      instance_eval(&RedactQueueProc)
    end
  end
end
