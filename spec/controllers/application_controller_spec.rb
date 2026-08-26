require 'rails_helper'

describe ApplicationController do
  describe '#resource_not_found' do
    let(:request) do
      instance_double(
        ActionDispatch::Request,
        raw_request_method: 'GET',
        filtered_path: '/missing',
        remote_ip: '127.0.0.1'
      )
    end

    before do
      allow(controller).to receive(:request).and_return(request)
    end

    it 'logs a structured warning without an exception' do
      expect(Lumen::NOT_FOUND_LOGGER).to receive(:warn).once.with({
        message: 'Request not found',
        status: 404,
        request_method: 'GET',
        request_path: '/missing',
        remote_ip: '127.0.0.1'
      })

      controller.send(:log_not_found, nil)
    end

    it 'records the exception class without its stack trace' do
      exception = ActiveRecord::RecordNotFound.new('Missing record')

      expect(Lumen::NOT_FOUND_LOGGER).to receive(:warn).once.with({
        message: 'Request not found',
        status: 404,
        request_method: 'GET',
        request_path: '/missing',
        remote_ip: '127.0.0.1',
        exception_class: 'ActiveRecord::RecordNotFound'
      })

      controller.send(:log_not_found, exception)
    end
  end

  describe '#after_sign_in_path_for' do
    it 'sends pro enterprise users to their dashboard' do
      account = create(:enterprise_account, plan: 'pro')
      user = create(:user, :enterprise, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(enterprise_root_path)
    end

    it 'sends a confirmed not-yet-pro enterprise user to settings to choose a plan' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(enterprise_account_path)
    end

    it 'sends an unconfirmed enterprise user home' do
      account = create(:enterprise_account, :inactive)
      user = create(:user, :enterprise, :unconfirmed_enterprise_email, enterprise_account: account)

      expect(controller.after_sign_in_path_for(user)).to eq(root_path)
    end
  end
end
