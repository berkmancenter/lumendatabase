require 'spec_helper'
require 'rails_admin/config/actions/redact_queue'

describe RedactQueueProc do
  include RailsAdminActionContext

  before { setup_action_context }

  context "GET request" do
    before do
      queue = stub_new(Redaction::Queue, current_user)
      queue.stub(:notices).and_return([])
    end

    it "assigns a refill instance" do
      refill = Redaction::RefillQueue.new(params)
      Redaction::RefillQueue.should_receive(:new).with(params).and_return(refill)

      instance_eval(&RedactQueueProc)

      expect(@refill).to eq refill
    end

    it "assigns objects from the user's queue" do
      queue = Redaction::Queue.new(current_user)
      queue.stub(:notices).and_return(:notices)
      Redaction::Queue.should_receive(:new).with(current_user).and_return(queue)

      instance_eval(&RedactQueueProc)

      expect(@objects).to eq :notices
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
    before { request.stub(:post?).and_return(true) }

    it "fills the users queue before redirecting" do
      params[:fill_queue] = true
      queue = stub_new(Redaction::Queue, current_user)
      refill = stub_new(Redaction::RefillQueue, params)
      refill.should_receive(:fill).with(queue)
      should_receive(:redact_queue_path).with(@abstract_model).and_return(:path)
      should_receive(:redirect_to).with(:path)
      should_not_receive(:respond_to)

      instance_eval(&RedactQueueProc)
    end

    it "releases notices and redirects if required" do
      params[:selected] = %w( 1 3 5 9 )
      params[:release_selected] = true
      queue = stub_new(Redaction::Queue, current_user)
      queue.should_receive(:release).with(%w( 1 3 5 9 ))
      should_receive(:redact_queue_path).with(@abstract_model).and_return(:path)
      should_receive(:redirect_to).with(:path)
      should_not_receive(:respond_to)

      instance_eval(&RedactQueueProc)
    end

    it "redirects to redact notice with the proper parameters" do
      params[:selected] = %w( 1 3 5 9 )
      should_receive(:redact_notice_path).
        with(@abstract_model, '1', next_notices: %w( 3 5 9 )).
        and_return(:path)
      should_receive(:redirect_to).with(:path)
      should_not_receive(:respond_to)

      instance_eval(&RedactQueueProc)
    end
  end

  def stub_new(klass, *args)
    klass.new(*args).tap do |instance|
      klass.stub(:new).and_return(instance)
    end
  end
end
