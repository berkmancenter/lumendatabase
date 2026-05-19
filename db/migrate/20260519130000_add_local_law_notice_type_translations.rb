class AddLocalLawNoticeTypeTranslations < ActiveRecord::Migration[7.1]
  def change
    Translation.find_or_create_by!(key: 'notice_type_descriptions_LocalLaw') do |translation|
      translation.body = 'Is the notice about a violation of law within a particular jurisdiction?'
    end

    Translation.find_or_create_by!(key: 'submitter_widget_type_descriptions_LocalLaw') do |translation|
      translation.body = 'Are you reporting a request to remove material online because of a violation of law within a particular jurisdiction?'
    end
  end
end
