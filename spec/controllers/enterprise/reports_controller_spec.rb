require 'rails_helper'

describe Enterprise::ReportsController do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) do
    create(
      :user,
      :enterprise,
      email: 'client@example.com',
      enterprise_account: enterprise_account
    )
  end

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#create' do
    before do
      allow(EnterpriseReportJob).to receive(:perform_later)
    end

    it 'creates a pending report and enqueues generation' do
      expect do
        post :create, params: {
          enterprise_report: {
            starts_on: '2026-06-01',
            ends_on: '2026-06-15'
          }
        }
      end.to change(EnterpriseReport, :count).by(1)

      report = EnterpriseReport.last

      expect(report.enterprise_account).to eq(enterprise_account)
      expect(report.requested_by).to eq(user)
      expect(report.requested_by_email).to eq('client@example.com')
      expect(report.starts_at).to eq(Time.zone.local(2026, 6, 1).beginning_of_day)
      expect(report.ends_at).to be_within(0.000001).of(
        Time.zone.local(2026, 6, 15).end_of_day
      )
      expect(report).to be_pending
      expect(EnterpriseReportJob).to have_received(:perform_later).with(report.id)
      expect(response).to redirect_to(enterprise_settings_path)
    end

    it 'rejects an invalid period' do
      expect do
        post :create, params: {
          enterprise_report: {
            starts_on: '2026-06-15',
            ends_on: '2026-06-01'
          }
        }
      end.not_to change(EnterpriseReport, :count)

      expect(EnterpriseReportJob).not_to have_received(:perform_later)
      expect(response).to redirect_to(enterprise_settings_path)
      expect(flash[:alert]).to eq('End date must be on or after start date.')
    end

    it 'requires active Enterprise Pro access' do
      inactive_account = create(:enterprise_account, :inactive)
      inactive_user = create(:user, :enterprise, enterprise_account: inactive_account)
      allow(controller).to receive(:current_user).and_return(inactive_user)

      expect do
        post :create, params: {
          enterprise_report: {
            starts_on: '2026-06-01',
            ends_on: '2026-06-15'
          }
        }
      end.not_to change(EnterpriseReport, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe '#show' do
    it 'downloads a ready report by token without requiring a signed-in user' do
      allow(controller).to receive(:current_user).and_return(nil)
      report = create(:enterprise_report)
      report.attach_json!('{"notices":[]}')

      get :show, params: { token: report.download_token }

      expect(response).to be_successful
      expect(response.media_type).to eq('application/json')
      expect(response.body).to eq('{"notices":[]}')
      expect(response.headers['Content-Disposition']).to include(
        report.download_filename
      )
    end

    it 'does not download a report before it is ready' do
      report = create(:enterprise_report)

      get :show, params: { token: report.download_token }

      expect(response).to have_http_status(:not_found)
    end
  end
end
