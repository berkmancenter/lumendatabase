require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

RedactQueueProc = Proc.new do
  queue = Redaction::Queue.new(current_user)
  refill = Redaction::RefillQueue.new(params)

  if request.post?
    if params[:fill_queue].present?
      refill.fill(queue)
      redirect_to redact_queue_path(@abstract_model)
    elsif params[:release_selected].present?
      queue.release(params[:selected])
      redirect_to redact_queue_path(@abstract_model)
    elsif params[:mark_selected_as_spam].present?
      queue.mark_as_spam(params[:selected])
      redirect_to redact_queue_path(@abstract_model)
    elsif params[:selected].present?
      notice_id, *next_notices = params[:selected]
      redact_path = redact_notice_path(
        @abstract_model,
        notice_id,
        next_notices: next_notices
      )

      redirect_to(redact_path)
    end
  else
    @refill = refill
    @objects = queue.notices

    respond_to do |format|
      format.html { render @action.template_name }
      format.js   { render @action.template_name, :layout => false }
    end
  end
end

module RailsAdmin
  module Config
    module Actions
      class RedactQueue < Base
        register_instance_option(:only) { 'Notice' }
        register_instance_option(:link_icon) { 'icon-adjust' }
        register_instance_option(:action_name) { :redact_queue }
        register_instance_option(:collection) { true }
        register_instance_option(:http_methods) { %i( get post ) }
        register_instance_option(:controller) { RedactQueueProc }
      end

      register RedactQueue
    end
  end
end
