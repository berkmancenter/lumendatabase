require 'rails_helper'
require 'base64'

describe NoticesController do
  context '#show' do
    it 'finds the notice by ID' do
      notice = Notice.new
      expect(Notice).to receive(:find_by).with(id: '42').and_return(notice)

      get :show, params: { id: 42 }

      expect(assigns(:notice)).to eq notice
    end

    context 'as HTML' do
      it 'renders the show template' do
        stub_find_notice

        get :show, params: { id: 1 }

        expect(response).to be_successful
        expect(response).to render_template(:show)
      end

      it 'renders a processing page for a reserved notice ID' do
        submission_request = create(:notice_submission_request)

        get :show, params: { id: submission_request.reserved_notice_id }

        expect(response).to have_http_status(:accepted)
        expect(response).to render_template(:processing)
      end

      it 'does not load the submission payload while polling' do
        submission_request = build_stubbed(:notice_submission_request)
        receipt_scope = instance_double(ActiveRecord::Relation)
        allow(Notice).to receive(:find_by).and_return(nil)
        expect(NoticeSubmissionRequest).to receive(:select)
          .with(:id, :reserved_notice_id, :status)
          .and_return(receipt_scope)
        expect(receipt_scope).to receive(:find_by)
          .with(reserved_notice_id: submission_request.reserved_notice_id.to_s)
          .and_return(submission_request)

        get :show, params: { id: submission_request.reserved_notice_id }

        expect(response).to have_http_status(:accepted)
      end

      it 'renders the rescinded template if the notice is rescinded' do
        stub_find_notice(build(:dmca, rescinded: true))

        get :show, params: { id: 1 }

        expect(response).to be_successful
        expect(response).to render_template(:rescinded)
      end

      it 'renders the unavailable template if the notice is spam' do
        stub_find_notice(build(:dmca, spam: true))

        get :show, params: { id: 1 }

        expect(response.status).to eq(404)
        expect(response).to render_template('error_pages/404_unavailable')
      end

      it 'renders the unavailable template if the notice is unpublished' do
        stub_find_notice(build(:dmca, published: false))

        get :show, params: { id: 1 }

        expect(response.status).to eq(404)
        expect(response).to render_template('error_pages/404_unavailable')
      end

      it 'renders the hidden template if the notice is hidden' do
        stub_find_notice(build(:dmca, hidden: true))

        get :show, params: { id: 1 }

        expect(response.status).to eq(404)
        expect(response).to render_template('error_pages/404_hidden')
      end

      it 'hides Google submissions from South Korea without updating the hidden field' do
        notice = build(:dmca, role_names: %w[submitter sender])
        notice.submitter.name = 'Google LLC'
        notice.sender.country_code = 'KR'
        stub_find_notice(notice)

        get :show, params: { id: 1 }

        expect(notice[:hidden]).to be false
        expect(response.status).to eq(404)
        expect(response).to render_template('error_pages/404_hidden')
      end

      it 'does not enqueue server-side tracking for HTML views' do
        stub_const('Piwik', Piwik.merge('disabled' => false))
        allow(MatomoTrackingJob).to receive(:perform_later)

        notice = stub_find_notice(create(:dmca))

        get :show, params: { id: notice.id }

        expect(MatomoTrackingJob).not_to have_received(:perform_later)
      end

      it 'stores a stable visitor id for browser tracking' do
        stub_const('Piwik', Piwik.merge('disabled' => false))
        notice = stub_find_notice(create(:dmca))

        get :show, params: { id: notice.id }

        visitor_id = controller.send(:matomo_visitor_id)

        expect(visitor_id).to match(/\A[0-9a-f]{16}\z/)
        expect(controller.send(:cookies)[:matomo_visitor_id]).to eq(visitor_id)
      end
    end

    context 'as JSON' do
      it 'returns processing status for a reserved notice ID' do
        submission_request = create(:notice_submission_request)

        get :show,
            params: { id: submission_request.reserved_notice_id, format: :json }

        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)).to eq(
          'notice' => {
            'id' => submission_request.reserved_notice_id,
            'status' => 'processing'
          }
        )
      end

      Notice.type_models.each do |model_class|
        it "returns a serialized notice for #{model_class}" do
          notice = stub_find_notice(model_class.new)

          serializer_class = notice.model_serializer || NoticeSerializer
          serialized = serializer_class.new(notice)

          expect(serializer_class).to receive(:new)
            .with(notice)
            .and_return(serialized)

          get :show, params: { id: 1, format: :json }

          json = JSON.parse(response.body)[model_class.to_s.tableize.singularize]
          expect(json).to have_key('id').with_value(notice.id)
          expect(json).to have_key('title').with_value(notice.title)
          expect(json).to have_key('sender_name')
        end
      end

      it "returns id, title and 'Notice Rescinded' as body for a rescinded notice" do
        notice = build(:dmca, rescinded: true)
        stub_find_notice(notice)

        get :show, params: { id: 1, format: :json }

        json = JSON.parse(response.body)['dmca']
        expect(json).to have_key('id').with_value(notice.id)
        expect(json).to have_key('title').with_value(notice.title)
        expect(json).to have_key('body').with_value('Notice Rescinded')
      end

      [
        ['hidden', { hidden: true }],
        ['spam', { spam: true }],
        ['unpublished', { published: false }]
      ].each do |notice_state, notice_attributes|
        it "returns not found for #{notice_state} notices unless the user is a super admin" do
          stub_find_notice(build(:dmca, notice_attributes))
          allow(controller).to receive(:current_user)
            .and_return(build(:user, :researcher))

          get :show, params: { id: 1, format: :json }

          expect(response).to have_http_status(:not_found)
        end

        it "returns #{notice_state} notices for super admins" do
          notice = stub_find_notice(build(:dmca, notice_attributes.merge(id: 1)))
          allow(controller).to receive(:current_user)
            .and_return(build(:user, :super_admin))

          get :show, params: { id: 1, format: :json }

          json = JSON.parse(response.body)['dmca']
          expect(response).to be_successful
          expect(json).to have_key('id').with_value(notice.id)
        end
      end

      it 'tracks JSON views with Matomo usage dimensions' do
        stub_const('Piwik', Piwik.merge('disabled' => false))
        allow(MatomoTrackingJob).to receive(:perform_later)
        set_matomo_dimension_settings

        user = create(:user, :researcher, email: 'api-user@example.test')
        notice = stub_find_notice(create(:dmca))

        get :show, params: {
          id: notice.id,
          authentication_token: user.authentication_token,
          format: :json
        }

        expect(MatomoTrackingJob).to have_received(:perform_later).with(
          hash_including(
            'dimension1' => 'credentialed',
            'dimension2' => 'api token',
            'dimension3' => 'api',
            'dimension4' => 'api-user@example.test',
            uid: 'api-user@example.test'
          )
        )
      end

      it 'does not enqueue tracking when server-side tracking is disabled' do
        stub_const(
          'Piwik',
          Piwik.merge('disabled' => false, 'server_tracking_enabled' => false)
        )
        allow(MatomoTrackingJob).to receive(:perform_later)
        notice = stub_find_notice(create(:dmca))

        get :show, params: { id: notice.id, format: :json }

        expect(MatomoTrackingJob).not_to have_received(:perform_later)
      end

      it 'overrides IP and timestamp when a Matomo API token is configured' do
        stub_const('Piwik', Piwik.merge('disabled' => false, 'token_auth' => 'secret-token'))
        allow_any_instance_of(ActionDispatch::Request)
          .to receive(:remote_ip)
          .and_return('203.0.113.42')
        payload = capture_matomo_payload
        notice = stub_find_notice(create(:dmca))

        get :show, params: { id: notice.id, format: :json }

        expect(payload).to include(
          cip: '203.0.113.42',
          token_auth: 'secret-token'
        )
        expect(payload[:cdt]).to be_present
      end

      it 'derives a stable cookieless visitor id for API requests' do
        stub_const('Piwik', Piwik.merge('disabled' => false))
        user = create(:user, :researcher, email: 'api-user@example.test')
        notice = stub_find_notice(create(:dmca))

        payload = capture_matomo_payload
        get :show, params: { id: notice.id, authentication_token: user.authentication_token, format: :json }
        first_id = payload[:_id]

        payload = capture_matomo_payload
        get :show, params: { id: notice.id, authentication_token: user.authentication_token, format: :json }

        expect(first_id).to match(/\A[0-9a-f]{16}\z/)
        expect(payload[:_id]).to eq(first_id)
        expect(response.cookies['matomo_visitor_id']).to be_nil
      end

      it 'returns original URLs for a Notice if you are a researcher' do
        user = create(:user, roles: [Role.researcher])
        params = {
          notice: {
            title: 'A title',
            type: 'DMCA',
            subject: 'Infringement Notfication via Blogger Complaint',
            date_sent: '2013-05-22',
            date_received: '2013-05-23',
            works_attributes: [
              {
                description: 'The Avengers',
                infringing_urls_attributes: [
                  { url: 'http://youtube.com/bad_url_1' },
                  { url: 'http://youtube.com/bad_url_2' },
                  { url: 'http://youtube.com/bad_url_3' }
                ]
              }
            ],
            entity_notice_roles_attributes: [
              {
                name: 'recipient',
                entity_attributes: {
                  name: 'Google',
                  kind: 'organization',
                  address_line_1: '1600 Amphitheatre Parkway',
                  city: 'Mountain View',
                  state: 'CA',
                  zip: '94043',
                  country_code: 'US'
                }
              },
              {
                name: 'sender',
                entity_attributes: {
                  name: 'Joe Lawyer',
                  kind: 'individual',
                  address_line_1: '1234 Anystreet St.',
                  city: 'Anytown',
                  state: 'CA',
                  zip: '94044',
                  country_code: 'US'
                }
              }
            ]
          }
        }

        notice = Notice.new(params[:notice])
        notice.save
        stub_find_notice(notice)

        get :show, params: { id: 1, format: :json }

        json = JSON.parse(response.body)['dmca']['works'][0]['infringing_urls'][0]
        expect(json).to have_key('count')
        expect(json).to have_key('fqdn')

        get :show, params: {
          id: 1, authentication_token: user.authentication_token, format: :json
        }

        json = JSON.parse(response.body)["dmca"]["works"][0]["infringing_urls"][0]
        expect(json).to have_key('url')
        expect(json).not_to have_key('url_original')
      end
    end

    context 'by notice_viewer' do
      let(:notice) { build(:dmca) }
      let(:user) do
        build(
          :user,
          :notice_viewer
        )
      end

      it 'increases the notice counter for the user when the viewing limit is set and viewing html' do
        expect(Notice).to receive(:find_by).with(id: '42').and_return(notice)

        user.full_notice_views_limit = 1
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 42 }

        expect(user.viewed_notices).to eq 1
      end

      it "won't increase the notice counter for the user when the viewing limit is set and viewing json" do
        expect(Notice).to receive(:find_by).with(id: '42').and_return(notice)

        user.full_notice_views_limit = 1
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 42, format: :json }

        expect(user.viewed_notices).to eq 0
      end

      it "won't increase the notice counter for the user when the viewing limit is nil or 0" do
        expect(Notice).to receive(:find_by).with(id: '42').exactly(2).times.and_return(notice)

        user.full_notice_views_limit = nil
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 42, format: :json }

        expect(user.viewed_notices).to eq 0

        user.full_notice_views_limit = 0

        get :show, params: { id: 42, format: :json }

        expect(user.viewed_notices).to eq 0
      end

      it 'increases the notice counter for the user when the viewing limit is set until the limit is reached' do
        expect(Notice).to receive(:find_by).with(id: '42').exactly(3).times.and_return(notice)

        user.full_notice_views_limit = 2
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 42 }

        expect(user.viewed_notices).to eq 1

        get :show, params: { id: 42 }

        expect(user.viewed_notices).to eq 2

        get :show, params: { id: 42 }

        expect(user.viewed_notices).to eq 2
      end
    end

    context 'updates stats' do
      let(:notice) { build(:dmca) }
      let(:notice_viewer_user) do
        build(
          :user,
          :notice_viewer
        )
      end

      it 'increases the notice views counter for an anonymous user' do
        notice.views_overall = 0
        notice.views_by_notice_viewer = 0

        expect(Notice).to receive(:find_by).twice.with(id: '42').and_return(notice)

        allow(controller).to receive(:current_user).and_return(nil)

        get :show, params: { id: 42 }
        get :show, params: { id: 42 }

        expect(notice.views_overall).to eq 2
        expect(notice.views_by_notice_viewer).to eq 0
      end

      it 'increases the notice notice_viewer views counter for a user with the notice_viewer role' do
        notice.views_overall = 50
        notice.views_by_notice_viewer = 5

        expect(Notice).to receive(:find_by).exactly(3).times.with(id: '42').and_return(notice)

        allow(controller).to receive(:current_user).and_return(notice_viewer_user)

        get :show, params: { id: 42 }
        get :show, params: { id: 42 }
        get :show, params: { id: 42 }

        expect(notice.views_overall).to eq 53
        expect(notice.views_by_notice_viewer).to eq 8
      end

      it 'increases the token url temp views counter' do
        expect(Notice).to receive(:find_by).exactly(6).times.with(id: '42').and_return(notice)

        token_url = TokenUrl.create!(
          email: 'test_user@lumendatabase.org',
          valid_forever: false,
          notice: notice
        )

        allow(controller).to receive(:current_user).and_return(notice_viewer_user)

        get :show, params: { id: 42, access_token: token_url.token }
        get :show, params: { id: 42, access_token: token_url.token }
        get :show, params: { id: 42, access_token: token_url.token }

        token_url.reload
        expect(token_url.views).to eq 3

        token_url = TokenUrl.create!(
          user: notice_viewer_user,
          email: 'test_user@lumendatabase.org',
          valid_forever: true,
          notice: notice
        )

        get :show, params: { id: 42, access_token: token_url.token }
        get :show, params: { id: 42, access_token: token_url.token }
        get :show, params: { id: 42, access_token: token_url.token }

        token_url.reload
        expect(token_url.views).to eq 3
      end
    end

    def stub_find_notice(notice = nil)
      notice ||= Notice.new
      notice.tap { |n| allow(Notice).to receive(:find_by).and_return(n) }
    end

    def capture_matomo_payload
      set_matomo_dimension_settings
      {}.tap do |captured|
        allow(MatomoTrackingJob).to receive(:perform_later) do |payload|
          captured.replace(payload)
        end
      end
    end

    def set_matomo_dimension_settings
      {
        matomo_dimension_credential_status_id: 1,
        matomo_dimension_auth_method_id: 2,
        matomo_dimension_surface_id: 3,
        matomo_dimension_authenticated_user_email_id: 4
      }.each do |key, value|
        setting = LumenSetting.find_or_initialize_by(key: key.to_s)
        setting.update!(
          name: key.to_s.humanize,
          value: value.to_s
        )
      end
    end
  end

  context '#create' do
    before do
      @fake_notice = double('Notice').as_null_object
      @notice_params = ActiveSupport::HashWithIndifferentAccess.new(title: 'A title')
    end

    def make_allowances
      allow(subject).to receive(:authorized_to_create?).and_return true
      allow(Lumen::NoticeBuilder).to receive(:new).and_return @fake_notice
      allow(@fake_notice).to receive(:id).and_return 1
      allow(@fake_notice).to receive(:errors).and_return []
    end

    context 'format-independent logic' do
      it 'initializes a DMCA by default from params' do
        make_allowances

        expect(Lumen::NoticeBuilder).to receive(:new)
          .with(DMCA, @notice_params, anything)

        post :create, params: { notice: @notice_params }
      end

      it 'uses the type param to instantiate the correct class' do
        make_allowances

        expect(Lumen::NoticeBuilder).to receive(:new)
          .with(Trademark, @notice_params, anything)

        post :create, params: {
          notice: @notice_params.merge(type: 'trademark')
        }
      end

      it 'defaults to DMCA if the type is missing or invalid' do
        invalid_types = ['', 'FlimFlam', 'Object', 'User', 'Hash']

        make_allowances
        expect(Lumen::NoticeBuilder).to receive(:new)
          .exactly(5).times
          .with(DMCA, @notice_params, anything)
          .and_return(@fake_notice)

        invalid_types.each do |invalid_type|
          post :create, params: {
            notice: @notice_params.merge(type: invalid_type)
          }
        end
      end
    end

    context 'as HTML' do
      it 'renders the new template when unsuccessful' do
        make_allowances
        allow(@fake_notice).to receive(:valid?).and_return(false)

        post_create

        expect(assigns(:notice)).to eq @fake_notice
        expect(response).to render_template(:new)
      end

      it 'continues to save HTML submissions synchronously' do
        make_allowances

        expect(@fake_notice).to receive(:save)
        expect(NoticeSubmissionRequest).not_to receive(:create!)

        post_create
      end
    end

    context 'as JSON' do
      before do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        @ability.can(:submit, Notice)
        allow(controller).to receive(:current_ability) { @ability }
      end

      it 'returns unauthorized if one cannot submit' do
        # Don't stub authorized_to_create? here -- we want to be implementation-
        # independent.
        @ability.cannot(:submit, Notice)
        response_body = { documentation_link: Rails.configuration.x.api_documentation_link }.to_json
        post_create :json

        expect(response.status).to eq 401
        expect(response.body).to eq response_body
      end

      it 'returns a proper Location header when saved successfully' do
        make_allowances
        enqueued_request_id = nil
        expect(NoticeSubmissionJob).to receive(:perform_later) do |request_id|
          enqueued_request_id = request_id
          expect(NoticeSubmissionRequest.find(request_id).queued_at).to be_present
        end

        expect do
          post_create :json
        end.to change(NoticeSubmissionRequest, :count).by(1)
          .and change(Notice, :count).by(0)

        submission_request = NoticeSubmissionRequest.last

        expect(response).to have_http_status(:created)
        expect(response.body).to be_empty
        expect(response.headers['Location']).to eq(
          notice_url(submission_request.reserved_notice_id)
        )
        expect(enqueued_request_id).to eq(submission_request.id)
      end

      it 'returns created after durable storage even if enqueueing fails' do
        make_allowances
        allow(NoticeSubmissionJob).to receive(:perform_later)
          .and_raise(RedisClient::CannotConnectError, 'redis unavailable')

        expect do
          post_create :json
        end.to change(NoticeSubmissionRequest, :count).by(1)

        expect(response).to have_http_status(:created)
        submission_request = NoticeSubmissionRequest.last
        expect(submission_request.status).to eq('received')
        expect(submission_request.queued_at).to be_nil
      end

      context 'with real notice validation' do
        let(:payload) { attributes_for(:notice_submission_request)[:payload] }

        before do
          allow(NoticeSubmissionJob).to receive(:perform_later)
        end

        it 'leaves entity inserts and deduplication to the worker' do
          payload['entity_notice_roles_attributes'] = %w[recipient sender].map do |role|
            { 'name' => role, 'entity_attributes' => { 'name' => 'New intake entity' } }
          end
          sql = []
          capture_sql = ->(*event) { sql << event.last[:sql] }

          expect do
            ActiveSupport::Notifications.subscribed(capture_sql, 'sql.active_record') do
              post :create, params: { notice: payload, format: :json }
            end
          end.not_to change { entity_sequence_state }

          expect(response).to have_http_status(:created)
          expect(sql.grep(/(?:INSERT INTO|UPDATE|DELETE FROM|FROM) "entities"/i)).to be_empty
          expect(Entity.where(name: 'New intake entity')).not_to exist
          submission_request = NoticeSubmissionRequest.last

          expect do
            NoticeSubmissionJob.perform_now(submission_request.id)
          end.to change(Entity, :count).by(1)

          notice = submission_request.reload.notice
          expect(submission_request).to be_completed
          expect(notice.recipient).to eq(notice.sender)
          expect(notice.recipient.name).to eq('New intake entity')
        end

        it 'does not consume entity IDs when the notice fails validation' do
          payload['works_attributes'] = []

          expect do
            post :create, params: { notice: payload, format: :json }
          end.not_to change { entity_sequence_state }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(NoticeSubmissionRequest.count).to eq(0)
          expect(Entity.count).to eq(0)
        end

        [
          { 'name' => '' },
          { 'kind' => 'invalid-kind' },
          { 'address_line_1' => 'x' * 256 }
        ].each do |invalid_attributes|
          it "rejects invalid nested entity #{invalid_attributes.keys.first} before accepting a receipt" do
            payload['entity_notice_roles_attributes'].first['entity_attributes']
              .merge!(invalid_attributes)

            expect do
              post :create, params: { notice: payload, format: :json }
            end.not_to change { entity_sequence_state }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['notices']).to have_key('entity_notice_roles.entity')
            expect(NoticeSubmissionRequest.count).to eq(0)
          end
        end

        it 'accepts an existing entity by ID without changing it' do
          entity = create(:entity)
          payload['entity_notice_roles_attributes'] = [{
            'name' => 'recipient', 'entity_id' => entity.id
          }]

          expect do
            post :create, params: { notice: payload, format: :json }
          end.not_to change { entity.reload.attributes }

          expect(response).to have_http_status(:created)
        end

        def entity_sequence_state
          Entity.connection.select_one(
            "SELECT last_value, is_called FROM #{Entity.connection.quote_table_name(Entity.sequence_name)}"
          )
        end
      end

      it 'stores attachments without staging them before the response' do
        make_allowances
        file_data = Base64.strict_encode64('small file')
        @notice_params[:file_uploads_attributes] = [{
          kind: 'original',
          file: "data:text/plain;base64,#{file_data}",
          file_name: 'small.txt'
        }]
        validation_payload = nil
        allow(Lumen::NoticeBuilder).to receive(:new) do |_type, payload, _user|
          validation_payload = payload
          @fake_notice
        end
        allow(NoticeSubmissionJob).to receive(:perform_later)

        expect do
          post :create,
               params: { notice: @notice_params, format: :json }
        end.not_to change(ActiveStorage::Blob, :count)

        expect(response).to have_http_status(:created)
        expect(validation_payload).not_to have_key('file_uploads_attributes')
        expect(
          NoticeSubmissionRequest.last.payload.dig(
            'file_uploads_attributes', 0, 'file'
          )
        ).to eq("data:text/plain;base64,#{file_data}")
      end

      it 'normalizes blank attachment kinds before storing the receipt' do
        make_allowances
        file_data = Base64.strict_encode64('small file')
        @notice_params[:file_uploads_attributes] = [{
          kind: '',
          file: "data:text/plain;base64,#{file_data}",
          file_name: 'small.txt'
        }]
        allow(NoticeSubmissionJob).to receive(:perform_later)

        post :create,
             params: { notice: @notice_params, format: :json }

        expect(response).to have_http_status(:created)
        expect(
          NoticeSubmissionRequest.last.payload.dig(
            'file_uploads_attributes', 0, 'kind'
          )
        ).to eq('supporting')
      end

      it 'rejects invalid attachment data before storing a receipt' do
        make_allowances
        allow(@fake_notice).to receive(:errors)
          .and_return(mock_errors(@fake_notice))
        @notice_params[:file_uploads_attributes] = [{
          kind: 'original',
          file: 'data:text/plain;base64,not-base64!',
          file_name: 'broken.txt'
        }]

        expect do
          post :create,
               params: { notice: @notice_params, format: :json }
        end.not_to change(NoticeSubmissionRequest, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body).dig('notices', 'file_uploads'))
          .to include('contains invalid base64 data')
      end

      it 'rejects attachments that fail Paperclip spoof validation' do
        make_allowances
        allow(@fake_notice).to receive(:errors)
          .and_return(mock_errors(@fake_notice))
        file_data = Base64.strict_encode64('plain text')
        @notice_params[:file_uploads_attributes] = [{
          kind: 'supporting',
          file: "data:text/plain;base64,#{file_data}",
          file_name: 'something.jpg'
        }]

        expect do
          post :create,
               params: { notice: @notice_params, format: :json }
        end.not_to change(NoticeSubmissionRequest, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body).dig('notices', 'file_uploads'))
          .to include(/contents.*reported/)
      end

      it 'returns a useful status code when there are errors' do
        make_allowances
        allow(@fake_notice).to receive(:valid?).and_return(false)
        allow(@fake_notice).to receive(:errors).and_return(['bruh'])

        post_create :json

        expect(response).to be_unprocessable
      end

      it 'includes any errors in the response' do
        make_allowances
        allow(@fake_notice).to receive(:valid?).and_return(false)
        allow(@fake_notice).to receive(:errors).and_return(['bruh'])

        post_create :json

        json = JSON.parse(response.body)
        expect(json).to have_key('notices').with_value(['bruh'])
      end
    end

    private

    def post_create(format = :html)
      post :create, params: { notice: { title: 'A title' }, format: format }
    end

    def mock_errors(model, field_errors = {})
      ActiveModel::Errors.new(model).tap do |errors|
        field_errors.each do |field, message|
          errors.add(field, message)
        end
      end
    end
  end
end
