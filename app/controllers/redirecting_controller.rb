class RedirectingController < ApplicationController
  def show(class_model, finder_method_name)
    instance = class_model.send(finder_method_name, params[:id])

    if instance
      redirect_to(
        send("#{singular_model_name(class_model)}_path".to_sym, instance),
        status: :moved_permanently
      )
    else
      render file: 'public/404_unavailable', formats: [:html], status: :not_found, layout: false
    end
  end

  private

  def singular_model_name(class_model)
    class_model.name.tableize.singularize
  end
end
