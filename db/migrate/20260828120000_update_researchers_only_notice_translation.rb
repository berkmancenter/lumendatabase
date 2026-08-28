class UpdateResearchersOnlyNoticeTranslation < ActiveRecord::Migration[7.2]
  KEY = 'notice_show_works_only_for_researchers'.freeze
  NEW_BODY = 'The full version of this notice is viewable only by users with a Lumen researcher credential.'.freeze
  OLD_BODY = 'Thanks for your interest, but URLs from submitter ' \
             '<span class="lumen-badge">%{submitter_name}</span> are viewable only by users with a ' \
             'Lumen researcher credential.'.freeze

  def up
    Translation.find_by(key: KEY)&.update!(body: NEW_BODY)
  end

  def down
    Translation.find_by(key: KEY)&.update!(body: OLD_BODY)
  end
end
