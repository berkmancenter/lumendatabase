module RailsAdminHelper
  def redact_notice_form(abstract_model, object, params, method = :post, &block)
    options = {
      url: redact_notice_path(
        abstract_model, object.id, next_notices: params[:next_notices]
      ),
      as: abstract_model.param_key,
      html: {
        multipart: true,
        method: method
      }
    }

    simple_form_for(object, options, &block)
  end
end
