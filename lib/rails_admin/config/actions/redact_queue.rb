require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

RedactQueueProc = Proc.new do
  if request.post? && params[:selected].present?
    notice_id, *next_notices = params[:selected]
    redact_path = redact_notice_path(
      @abstract_model,
      notice_id,
      next_notices: next_notices
    )

    redirect_to(redact_path)
  else
    respond_to do |format|
      queue = Redaction::Queue.new(current_user)
      queue.fill

      @objects = queue.notices

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
