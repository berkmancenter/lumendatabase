require 'rails_helper'

feature 'content filters' do
  context 'full_notice_version_only_lumen_team action' do
    scenario 'filtered notice doesn\'t show a link to request a token' do
      ContentFilter.create(
        name: 'Test',
        query: '"entities"."name" = \'Stop\' ',
        actions: [:full_notice_version_only_lumen_team]
      )

      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.submitter.name = 'Stop'
      notice.submitter.save

      visit notice_url(notice)

      expect(page).not_to have_content('to request access and see full URLs')
    end

    scenario 'not filtered notice shows a link to request a token' do
      ContentFilter.create(
        name: 'Test',
        query: '"entities"."name" = \'Stop\' ',
        actions: [:full_notice_version_only_lumen_team]
      )

      notice = create(:dmca, :with_infringing_urls, role_names: %w[sender principal submitter])
      notice.submitter.name = 'No stop'
      notice.submitter.save

      visit notice_url(notice)

      expect(page).to have_content('to request access and see full URLs')
    end
  end
end
