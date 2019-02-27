require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper

  context '#can_see_full_notice_version?' do
    let(:notice) { create(:dmca) }
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
end
