require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  context '#can_see_full_notice_version?' do
    let(:notice) { build(:dmca) }
    let(:token_url) do
      create(
        :token_url,
        email: 'user@example.com',
        notice: notice
      )
    end

    it 'returns true when the user is allowed to see the full notice version' do
      allow_any_instance_of(ApplicationHelper).to receive(:params).and_return({access_token: token_url.token})
      allow_any_instance_of(ApplicationHelper).to receive(:can?).and_return(true)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(true)
    end

    it 'returns true when the user is not allowed to see the full notice version and the token is valid' do
      allow_any_instance_of(ApplicationHelper).to receive(:params).and_return({access_token: token_url.token})
      allow_any_instance_of(ApplicationHelper).to receive(:can?).and_return(false)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(true)
    end

    it 'returns false for a Lumen-team-only notice when the token is valid' do
      notice.full_notice_version_only_lumen_team = true
      allow_any_instance_of(ApplicationHelper).to receive(:params).and_return({access_token: token_url.token})
      allow_any_instance_of(ApplicationHelper).to receive(:can?).and_return(false)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(false)
    end

    it 'returns true for a Lumen-team-only safelisted notice' do
      notice.id = 1234
      notice.full_notice_version_only_lumen_team = true
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('SAFELISTED_NOTICES_FULL').and_return('1234')
      allow_any_instance_of(ApplicationHelper).to receive(:params).and_return({})
      allow_any_instance_of(ApplicationHelper).to receive(:can?).and_return(false)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(true)
    end

    it 'returns true when the user is allowed to see the full notice version and the token is not valid' do
      allow_any_instance_of(ApplicationHelper).to receive(:params).and_return({access_token: 'WHATEVER'})
      allow_any_instance_of(ApplicationHelper).to receive(:can?).and_return(true)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(true)
    end

    it 'returns false when the token is not valid and the user not allowed to see the full notice version' do
      allow_any_instance_of(ApplicationHelper).to receive(:params).and_return({access_token: 'WHATEVER'})
      allow_any_instance_of(ApplicationHelper).to receive(:can?).and_return(false)

      result = can_see_full_notice_version?(notice)

      expect(result).to eq(false)
    end
  end

  context '#client_navigation?' do
    it 'returns true in the client area' do
      allow(helper).to receive(:client_area?).and_return(true)
      allow(helper).to receive(:enterprise_notice_view?).and_return(false)

      expect(helper.client_navigation?).to eq(true)
    end

    it 'returns true on the client settings page' do
      allow(helper).to receive(:controller_path).and_return('client/settings')
      allow(helper).to receive(:action_name).and_return('show')

      expect(helper.client_navigation?).to eq(true)
    end

    it 'returns true for an active enterprise user on a notice show page' do
      user = build_stubbed(:user, :enterprise)

      allow(helper).to receive(:controller_path).and_return('notices')
      allow(helper).to receive(:action_name).and_return('show')
      allow(helper).to receive(:current_user).and_return(user)

      expect(helper.client_navigation?).to eq(true)
    end

    it 'returns false for public notice show pages without an active enterprise user' do
      allow(helper).to receive(:controller_path).and_return('notices')
      allow(helper).to receive(:action_name).and_return('show')
      allow(helper).to receive(:current_user).and_return(nil)

      expect(helper.client_navigation?).to eq(false)
    end
  end

  context '#application_header_classes' do
    it 'uses the search header sizing on the client settings page' do
      allow(helper).to receive(:controller_path).and_return('client/settings')

      expect(helper.application_header_classes).to eq('app search-header')
    end

    it 'uses the regular app header elsewhere' do
      allow(helper).to receive(:controller_path).and_return('notices')

      expect(helper.application_header_classes).to eq('app')
    end
  end
end
