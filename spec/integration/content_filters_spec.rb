require 'rails_helper'

feature 'content filters' do
  [
    ['full_notice_version_only_lumen_team', :admin],
    ['full_notice_version_only_researchers', :researcher],
  ].each do |action_data|
    context "#{action_data[0]} action" do
      scenario 'filtered notice doesn\'t show a link to request a token' do
        create_content_filter_for_action(action_data[0])

        notice = create(:dmca, role_names: %w[sender principal submitter])
        notice.submitter.name = 'Stop'
        notice.submitter.save

        visit notice_url(notice)

        expect(page).not_to have_content('to request access and see full URLs')
      end

      scenario 'admin can see filtered content' do
        create_content_filter_for_action(action_data[0])

        work1 = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/dude')])
        notice = create(:dmca, role_names: %w[sender principal submitter])
        notice.works = [work1]
        notice.submitter.name = 'Stop'
        notice.save

        sign_in(create(:user, action_data[1], full_notice_views_limit: nil))
        visit notice_url(notice)

        expect(page).to have_content('https://example.com/dude')
      end

      scenario 'not filtered notice shows a link to request a token' do
        create_content_filter_for_action(action_data[0])

        notice = create(:dmca, :with_infringing_urls, role_names: %w[sender principal submitter])
        notice.submitter.name = 'No stop'
        notice.submitter.save

        visit notice_url(notice)

        expect(page).to have_content('to request access and see full URLs')
      end
    end
  end

  private

  def create_content_filter_for_action(filter_name)
    ContentFilter.create(
      name: 'Test',
      query: '"entities"."name" = \'Stop\' ',
      actions: [filter_name]
    )
  end
end
