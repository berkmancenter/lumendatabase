require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

RedactNoticeProc = Proc.new do
  @redactable_fields = Notice::REDACTABLE_FIELDS
  @next_notice = @object.next_requiring_review

  if request.get?
    respond_to do |format|
      format.html { render @action.template_name }
      format.js   { render @action.template_name, :layout => false }
    end
  elsif request.put?
    attributes = params[@abstract_model.param_key]

    @redactable_fields.each do |field|
      @object.send(:"#{field}=", attributes[field])
      @object.send(:"#{field}_original=", attributes["#{field}_original"])
    end

    @object.review_required = attributes[:review_required]

    if @object.save
      respond_to do |format|
        format.html {
          if params[:save_and_next] && @next_notice
            redirect_to(
              redact_notice_path(@abstract_model, @next_notice.id)
            )
          else
            redirect_to_on_success
          end
        }
        format.js {
          render json: {
            id: @object.id.to_s,
            label: @model_config.with(object: @object).object_label
          }
        }
      end
    else
      handle_save_error :edit
    end
  end
end

module RailsAdmin
  module Config
    module Actions
      class RedactNotice < Edit
        register_instance_option(:only) { 'Notice' }
        register_instance_option(:action_name) { :redact_notice }
        register_instance_option(:link_icon) { 'icon-adjust' }
        register_instance_option(:controller) { RedactNoticeProc }
        register_instance_option :visible? do
          bindings && (object = bindings[:object]) &&
            object.respond_to?(:review_required) && object.review_required?
        end
      end

      register RedactNotice
    end
  end
end
