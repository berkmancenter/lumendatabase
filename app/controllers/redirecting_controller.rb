class RedirectingController < ApplicationController

  def show(class_model, finder_method_name)
    # Try to find the Notice with the given ID number and ID type.
    # If there is no such notice, try finding one with that ID number for the
    # standard :id -- we think outside parties' scripts are interpolating new
    # notice ID numbers into old format URLs.
    # 404 only if neither of these is found.
    if (instance = class_model.send(finder_method_name, params[:id]))
      redirect_to(
        send("#{singular_model_name(class_model)}_path".to_sym, instance),
        status: :moved_permanently
      )
    elsif (instance = class_model.send(:find_by_id, params[:id]))
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
