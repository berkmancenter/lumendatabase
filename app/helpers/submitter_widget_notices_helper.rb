module SubmitterWidgetNoticesHelper
  def submitter_widget_form_partial_for(instance)
    "notices/submitter_widget/#{instance.class.name.tableize.singularize}_form"
  end
end
