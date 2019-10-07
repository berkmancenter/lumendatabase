require 'rails_helper'

describe NoticesController do
  context '#show' do
    it 'finds the notice by ID' do
      notice = Notice.new
      expect(Notice).to receive(:find).with('42').and_return(notice)

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
        expect(response).to render_template(file: '404_unavailable.html')
      end

      it 'renders the unavailable template if the notice is unpublished' do
        stub_find_notice(build(:dmca, published: false))

        get :show, id: 1

        expect(response.status).to eq(404)
        expect(response).to render_template(file: '404_unavailable.html')
      end

      it 'renders the hidden template if the notice is hidden' do
        stub_find_notice(build(:dmca, hidden: true))

        get :show, params: { id: 1 }

        expect(response.status).to eq(404)
        expect(response).to render_template(file: '404_hidden.html')
      end
    end

    context 'as JSON' do
      Notice.type_models.each do |model_class|
        it "returns a serialized notice for #{model_class}" do
          notice = stub_find_notice(model_class.new)

          serializer_class = model_class.active_model_serializer || NoticeSerializer
          serialized = serializer_class.new(notice)

          allow(serialized).to receive(:current_user).and_return(nil)
          expect(serializer_class).to receive(:new).
            with(notice, anything)
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
        expect(json).to have_key('domain')

        get :show, params: {
          id: 1, authentication_token: user.authentication_token, format: :json
        }

        json = JSON.parse(response.body)["dmca"]["works"][0]["infringing_urls"][0]
        expect(json).to have_key('url_original')
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
        expect(Notice).to receive(:find).with('42').and_return(notice)

        user.notice_viewer_views_limit = 1
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 42 }

        expect(user.notice_viewer_viewed_notices).to eq 1
      end

      it "won't increase the notice counter for the user when the viewing limit is set and viewing json" do
        expect(Notice).to receive(:find).with('42').and_return(notice)

        user.notice_viewer_views_limit = 1
        allow(controller).to receive(:current_user).and_return(user)

        get :show, params: { id: 42, format: :json }

        expect(user.notice_viewer_viewed_notices).to eq 0
      end

      it "won't increase the notice counter for the user when the viewing limit is nil or 0" do
        expect(Notice).to receive(:find).twice.with('42').and_return(notice)

        user.notice_viewer_views_limit = nil
        allow(controller).to receive(:current_user).and_return(user)

        get :show, id: 42, format: :json

        expect(user.notice_viewer_viewed_notices).to eq 0

        user.notice_viewer_views_limit = 0

        get :show, id: 42, format: :json

        expect(user.notice_viewer_viewed_notices).to eq 0
      end

      it 'increases the notice counter for the user when the viewing limit is set until the limit is reached' do
        expect(Notice).to receive(:find).with('42').exactly(3).times.and_return(notice)

        user.notice_viewer_views_limit = 2
        allow(controller).to receive(:current_user).and_return(user)

        get :show, id: 42

        expect(user.notice_viewer_viewed_notices).to eq 1

        get :show, id: 42

        expect(user.notice_viewer_viewed_notices).to eq 2

        get :show, id: 42

        expect(user.notice_viewer_viewed_notices).to eq 2
      end
    end

    def stub_find_notice(notice = nil)
      notice ||= Notice.new
      notice.tap { |n| allow(Notice).to receive(:find).and_return(n) }
    end
  end

  context '#create' do
    context 'format-independent logic' do
      before do
        @submit_notice = double('NoticeSubmissionInitializer').as_null_object
        @notice_params = HashWithIndifferentAccess.new(title: 'A title')
      end

      it 'initializes a DMCA by default from params' do
        expect(NoticeSubmissionInitializer).to receive(:new)
          .with(DMCA, @notice_params)
          .and_return(@submit_notice)

        post :create, notice: @notice_params
      end

      it 'uses the type param to instantiate the correct class' do
        expect(NoticeSubmissionInitializer).to receive(:new)
          .with(Trademark, @notice_params)
          .and_return(@submit_notice)

        post :create, notice: @notice_params.merge(type: 'trademark')
      end

      it 'defaults to DMCA if the type is missing or invalid' do
        invalid_types = ['', 'FlimFlam', 'Object', 'User', 'Hash']

        expect(NoticeSubmissionInitializer).to receive(:new)
          .exactly(5).times
          .with(DMCA, @notice_params)
          .and_return(@submit_notice)

        invalid_types.each do |invalid_type|
          post :create, notice: @notice_params.merge(type: invalid_type)
        end
      end

      it 'has the expected delayed parameters' do
        expect(NoticesController::DELAYED_PARAMS).to eq %i[works_attributes]
      end

      it 'initializes NoticeSubmissionInitializer without delayed parameters' do
        stub_submit_notice

        params = @notice_params
        params[:works_attributes] = [{
          description: 'The model of a modern major-general',
          kind: 'polymath',
          infringing_urls_attributes: ['https://url.one', 'https://url.two'],
          copyrighted_urls_attributes: ['https://url.three']
        }]

        expect(NoticeSubmissionInitializer).to receive(:new)
          .with(anything, params.except(:works_attributes))

        post :create, notice: params
      end

      it 'initializes NoticeSubmissionFinalizer with delayed parameters' do
        submit_notice = stub_submit_notice
        finalizer = stub_finalize_notice

        notice = build_stubbed(:dmca)

        allow(submit_notice).to receive(:notice).and_return(notice)
        allow(finalizer).to receive(:finalize).and_return(notice)

        params = @notice_params
        params[:works_attributes] = [{
          description: 'The model of a modern major-general',
          kind: 'polymath',
          infringing_urls_attributes: ['https://url.one', 'https://url.two'],
          copyrighted_urls_attributes: ['https://url.three']
        }]

        expect(NoticeSubmissionFinalizer).to receive(:new)
          .with(anything, hash_including(:works_attributes))

        post :create, notice: params
      end
    end

    context 'as HTML' do
      it 'redirects when saved successfully' do
        stub_submit_notice

        post_create

        expect(response).to redirect_to(:root)
      end

      it 'renders the new template when unsuccessful' do
        submit_notice = stub_submit_notice
        allow(submit_notice).to receive(:submit).and_return(false)

        post_create

        expect(assigns(:notice)).to eq submit_notice.notice
        expect(response).to render_template(:new)
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
        stub_submit_notice
        @ability.cannot(:submit, Notice)
        response_body = { documentation_link: Rails.configuration.x.api_documentation_link }.to_json
        post_create :json

        expect(response.status).to eq 401
        expect(response.body).to eq response_body
      end

      it 'returns a proper Location header when saved successfully' do
        notice = build_stubbed(:dmca)
        submit_notice = stub_submit_notice
        finalizer = stub_finalize_notice
        allow(submit_notice).to receive(:notice).and_return(notice)
        allow(finalizer).to receive(:finalize).and_return(notice)

        post_create :json

        expect(response).to be_successful
        expect(response.headers['Location']).to eq notice_url(notice)
      end

      it 'returns a useful status code when there are errors' do
        submit_notice = stub_submit_notice
        allow(submit_notice).to receive(:submit).and_return(false)

        post_create :json

        expect(response).to be_unprocessable
      end

      it 'includes any errors in the response' do
        submit_notice = stub_submit_notice
        allow(submit_notice).to receive(:submit).and_return(false)
        allow(submit_notice).to receive(:errors).and_return(
          mock_errors(submit_notice.notice, works: "can't be blank")
        )

        post_create :json

        json = JSON.parse(response.body)
        expect(json).to have_key('works').with_value(["can't be blank"])
      end
    end

    private

    def stub_submit_notice
      NoticeSubmissionInitializer.new(DMCA, {}).tap do |submit_notice|
        allow(submit_notice).to receive(:submit).and_return(true)
        allow(NoticeSubmissionInitializer).to receive(:new).and_return(submit_notice)
      end
    end

    def stub_finalize_notice
      NoticeSubmissionFinalizer.new(DMCA, {}).tap do |finalizer|
        allow(NoticeSubmissionFinalizer)
          .to receive(:new)
          .and_return(finalizer)
      end
    end

    def post_create(format = :html)
      post :create, notice: { title: 'A title' }, format: format
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
