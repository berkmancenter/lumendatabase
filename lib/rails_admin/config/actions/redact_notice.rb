require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

ActionResponder = Struct.new(:context, :abstract_model, :object)

class PostResponder < ActionResponder
  def handle(params)
    if params[:selected_text].present?
      redactor = RedactsNotices.new([
        RedactsNotices::RedactsContent.new(params[:selected_text])
                                    ])

      review_required_ids = Notice.where(review_required: true).pluck(:id)

      redactor.redact_all([object.id] + review_required_ids)
    end

    redirect_to_current(params)
  end

  private

  def redirect_to_current(params)
    context.redirect_to(context.redact_notice_path(
      abstract_model, object.id, next_notices: params[:next_notices]
    ))
  end
end

class PutResponder < ActionResponder
  def handle(params)
    attributes = params[abstract_model.param_key]

    Notice::REDACTABLE_FIELDS.each do |field|
      object.send(:"#{field}=", attributes[field])
      object.send(:"#{field}_original=", attributes["#{field}_original"])
    end

    object.review_required = attributes[:review_required]

    if object.save
      context.respond_to do |format|
        format.html { respond_html(params) }
        format.js { respond_json }
      end
    else
      handle_error
    end
  end

  private

  def respond_html(params)
    if params[:save_and_next]
      save_and_next(params)
    else
      context.redirect_to context.redact_queue_path(abstract_model)
    end
  end

  def respond_json
    context.render json: { id: object.id.to_s, label: "Redact notice" }
  end

  def handle_error
    context.handle_save_error :redact_notice
  end

  def save_and_next(params)
    next_notice, *next_notices = params[:next_notices]

    context.redirect_to(context.redact_notice_path(
      abstract_model, next_notice, next_notices: next_notices
    ))
  end
end

RedactNoticeProc = Proc.new do
  if request.post?
    post_responder = PostResponder.new(self, @abstract_model, @object)
    post_responder.handle(params)
  end

  if request.put?
    put_responder = PutResponder.new(self, @abstract_model, @object)
    put_responder.handle(params)
  end

  if request.get?
    @redactable_fields = Notice::REDACTABLE_FIELDS

    if params[:next_notices].present?
      next_notice, *next_notices = params[:next_notices]

      @next_notice_path = redact_notice_path(
        @abstract_model, next_notice, next_notices: next_notices
      )
    end

    respond_to do |format|
      format.html { render @action.template_name }
      format.js   { render @action.template_name, :layout => false }
    end
  end
end

module RailsAdmin
  module Config
    module Actions
      class RedactNotice < Base
        register_instance_option(:only) { 'Notice' }
        register_instance_option(:link_icon) { 'icon-adjust' }
        register_instance_option(:action_name) { :redact_notice }
        register_instance_option(:member) { true }
        register_instance_option(:http_methods) { %i( get post put ) }
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
