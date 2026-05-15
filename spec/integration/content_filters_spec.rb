require 'rails_helper'

feature 'content filters' do
  context 'notice-level researchers-only flag' do
    scenario 'flagged notice doesn\'t show a link to request a token' do
      notice = create(
        :dmca,
        :with_infringing_urls,
        full_notice_version_only_researchers: true,
        role_names: %w[sender principal submitter]
      )

      visit notice_url(notice)

      expect(page).not_to have_content('to request access and see full URLs')
      expect(page).to have_content('viewable only by users with a Lumen researcher credential')
    end

    scenario 'researcher can see flagged notice content' do
      work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/research')])
      notice = create(:dmca, full_notice_version_only_researchers: true, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      sign_in(create(:user, :researcher, full_notice_views_limit: nil))
      visit notice_url(notice)

      expect(page).to have_content('https://example.com/research')
    end
  end

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

  context 'url text filters' do
    scenario 'filtered notice does not show a link to request a token when an infringing url contains the text' do
      create_content_filter_for_action('full_notice_version_only_researchers', url_text: 'sensitive-name')

      work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/Sensitive-Name/report')])
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      visit notice_url(notice)

      expect(page).not_to have_content('to request access and see full URLs')
    end

    scenario 'filtered notice is visible to an allowed user when a copyrighted url contains the text' do
      create_content_filter_for_action('full_notice_version_only_researchers', url_text: 'sensitive-name')

      work = Work.new(copyrighted_urls: [CopyrightedUrl.new(url: 'https://example.com/sensitive-name/source')])
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      sign_in(create(:user, :researcher, full_notice_views_limit: nil))
      visit notice_url(notice)

      expect(page).to have_content('https://example.com/sensitive-name/source')
    end

    scenario 'does not match text outside of urls' do
      create_content_filter_for_action('full_notice_version_only_researchers', url_text: 'sensitive-name')

      work = Work.new(
        description: 'sensitive-name appears here',
        infringing_urls: [InfringingUrl.new(url: 'https://example.com/public/report')]
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      visit notice_url(notice)

      expect(page).to have_content('to request access and see full URLs')
    end
  end

  private

  def create_content_filter_for_action(filter_name, query: nil, url_text: nil)
    query = '"entities"."name" = \'Stop\' ' unless url_text.present? || query.present?

    ContentFilter.create(
      name: 'Test',
      query: query,
      url_text: url_text,
      actions: [filter_name]
    )
  end
end
