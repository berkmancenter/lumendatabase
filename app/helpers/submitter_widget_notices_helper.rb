module SubmitterWidgetNoticesHelper
  def form_partial_for(instance)
    "notices/submitter_widget/#{instance.class.name.tableize.singularize}_form"
  end
end
