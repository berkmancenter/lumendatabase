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
      expect(page).to have_content('The full version of this notice is viewable only by users with a Lumen researcher credential.')
    end

    scenario 'flagged notice without a submitter still renders the notice-level researchers-only message' do
      notice = create(
        :dmca,
        :with_infringing_urls,
        full_notice_version_only_researchers: true,
        role_names: %w[sender principal]
      )

      visit notice_url(notice)

      expect(page).to have_content('The full version of this notice is viewable only by users with a Lumen researcher credential.')
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

  context 'notice-level admins-only flag' do
    scenario 'flagged notice doesn\'t show a link to request a token' do
      notice = create(
        :dmca,
        :with_infringing_urls,
        full_notice_version_only_lumen_team: true,
        role_names: %w[sender principal submitter]
      )

      visit notice_url(notice)

      expect(page).not_to have_content('to request access and see full URLs')
    end

    scenario 'researcher cannot see flagged notice full URLs' do
      work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/admins-only')])
      notice = create(:dmca, full_notice_version_only_lumen_team: true, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      sign_in(create(:user, :researcher, full_notice_views_limit: nil))
      visit notice_url(notice)

      expect(page).not_to have_content('https://example.com/admins-only')
      expect(page).to have_content('example.com - 1 URL')
    end

    scenario 'valid token cannot reveal flagged notice full URLs' do
      work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/token-bypass')])
      notice = create(:dmca, full_notice_version_only_lumen_team: true, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save
      token_url = create(
        :token_url,
        notice: notice,
        expiration_date: Time.now + LumenSetting.get_i('truncation_token_urls_active_period').seconds
      )

      visit notice_url(notice, access_token: token_url.token)

      expect(page).not_to have_content('https://example.com/token-bypass')
      expect(page).to have_content('example.com - 1 URL')
    end

    scenario 'safelisted notice ID reveals flagged notice full URLs' do
      work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/safelisted')])
      notice = create(:dmca, full_notice_version_only_lumen_team: true, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('SAFELISTED_NOTICES_FULL').and_return(notice.id.to_s)

      visit notice_url(notice)

      expect(page).to have_content('https://example.com/safelisted')
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

      scenario 'filtered notice by URL text doesn\'t show a link to request a token' do
        create_content_filter_for_action(action_data[0], query: nil, url_text: 'sensitive-name')

        work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/Sensitive-Name/profile')])
        notice = create(:dmca, role_names: %w[sender principal submitter])
        notice.works = [work]
        notice.save

        visit notice_url(notice)

        expect(page).not_to have_content('to request access and see full URLs')
      end

      scenario 'URL-granularity filter still allows requesting full notice access' do
        create_content_filter_for_action(
          action_data[0],
          query: nil,
          url_text: 'sensitive-name',
          granularity: 'urls'
        )

        work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/Sensitive-Name/profile')])
        notice = create(:dmca, role_names: %w[sender principal submitter])
        notice.works = [work]
        notice.save

        visit notice_url(notice)

        expect(page).to have_content('to request access and see full URLs')
      end

      scenario 'URL-granularity filter handles only matching URLs in the full notice' do
        create_content_filter_for_action(
          action_data[0],
          query: nil,
          url_text: 'sensitive-name',
          granularity: 'urls'
        )

        work = Work.new(
          infringing_urls: [
            InfringingUrl.new(url: 'https://example.com/Sensitive-Name/profile'),
            InfringingUrl.new(url: 'https://example.org/public')
          ]
        )
        notice = create(:dmca, role_names: %w[sender principal submitter])
        notice.works = [work]
        notice.save
        token_url = create(
          :token_url,
          notice: notice,
          expiration_date: Time.now + LumenSetting.get_i('truncation_token_urls_active_period').seconds
        )

        visit notice_url(notice, access_token: token_url.token)

        expect(page).not_to have_content('https://example.com/Sensitive-Name/profile')
        expect(page).to have_content('example.com - 1 URL')
        expect(page).to have_content('https://example.org/public')
      end

      scenario 'permitted user can see URL text filtered content' do
        create_content_filter_for_action(action_data[0], query: nil, url_text: 'sensitive-name')

        work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/Sensitive-Name/profile')])
        notice = create(:dmca, role_names: %w[sender principal submitter])
        notice.works = [work]
        notice.save

        sign_in(create(:user, action_data[1], full_notice_views_limit: nil))
        visit notice_url(notice)

        expect(page).to have_content('https://example.com/Sensitive-Name/profile')
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

  context 'full_notice_version_only_lumen_team content filter' do
    scenario 'admin sees full URLs for URL-granularity Lumen-team-only filtered content' do
      create_content_filter_for_action(
        'full_notice_version_only_lumen_team',
        query: nil,
        url_text: 'sensitive-name',
        granularity: 'urls'
      )

      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://example.com/sensitive-name/profile'),
          InfringingUrl.new(url: 'https://example.com/sensitive-name/about')
        ]
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      sign_in(create(:user, :admin, full_notice_views_limit: nil))
      visit notice_url(notice)

      expect(page).to have_content('https://example.com/sensitive-name/profile')
      expect(page).to have_content('https://example.com/sensitive-name/about')
      expect(page).not_to have_content('example.com - 2 URLs')
    end

    scenario 'admin sees full URLs for URL-granularity Lumen-team-only domain-filtered content' do
      create_content_filter_for_action(
        'full_notice_version_only_lumen_team',
        query: nil,
        url_text: 'sensitive',
        granularity: 'urls'
      )

      work = Work.new(
        infringing_urls: [
          InfringingUrl.new(url: 'https://sensitive-domain.com/profile'),
          InfringingUrl.new(url: 'https://sensitive-domain.com/about')
        ]
      )
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.save

      sign_in(create(:user, :admin, full_notice_views_limit: nil))
      visit notice_url(notice)

      expect(page).to have_content('https://sensitive-domain.com/profile')
      expect(page).to have_content('https://sensitive-domain.com/about')
      expect(page).not_to have_content('[REDACTED]-domain.com')
    end

    scenario 'researcher cannot see filtered full URLs or request access' do
      create_content_filter_for_action('full_notice_version_only_lumen_team')

      work = Work.new(infringing_urls: [InfringingUrl.new(url: 'https://example.com/lumen-team-filtered')])
      notice = create(:dmca, role_names: %w[sender principal submitter])
      notice.works = [work]
      notice.submitter.name = 'Stop'
      notice.save

      sign_in(create(:user, :researcher, full_notice_views_limit: nil))
      visit notice_url(notice)

      expect(page).not_to have_content('https://example.com/lumen-team-filtered')
      expect(page).to have_content('example.com - 1 URL')
      expect(page).not_to have_content('to request access and see full URLs')
    end
  end

  private

  def create_content_filter_for_action(filter_name, query: '"entities"."name" = \'Stop\' ', url_text: nil, granularity: 'notice')
    ContentFilter.create!(
      name: 'Test',
      query: query,
      url_text: url_text,
      granularity: granularity,
      actions: [filter_name]
    )
  end
end
