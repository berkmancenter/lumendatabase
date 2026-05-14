require 'rails_helper'

RSpec.describe ApiSubmitterRequest, type: :model do
  describe '#approve_request' do
    subject(:request) do
      create(:api_submitter_request,
        email: 'requester@example.com',
        submissions_forward_email: 'forward@example.com',
        entity_name: 'Test Corp',
        entity_kind: 'organization',
        entity_address_line_1: 'Address 1',
        entity_address_line_2: 'Address 2',
        entity_state: 'State',
        entity_country_code: 'US',
        entity_phone: '555-555-1212',
        entity_url: 'http://www.example.com',
        entity_email: 'entity@example.com',
        entity_city: 'City',
        entity_zip: '01222'
      )
    end

    let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before do
      allow(ApiSubmitterRequestsMailer)
        .to receive(:api_submitter_request_approved)
        .and_return(mailer_double)
    end

    shared_examples 'completes approval' do
      it 'creates a new entity with correct attributes' do
        subject.approve_request

        entity = Entity.last
        expect(entity.name).to eq(subject.entity_name)
        expect(entity.kind).to eq(subject.entity_kind)
        expect(entity.address_line_1).to eq(subject.entity_address_line_1)
        expect(entity.address_line_2).to eq(subject.entity_address_line_2)
        expect(entity.state).to eq(subject.entity_state)
        expect(entity.country_code).to eq(subject.entity_country_code)
        expect(entity.phone).to eq(subject.entity_phone)
        expect(entity.url).to eq(subject.entity_url)
        expect(entity.email).to eq(subject.entity_email)
        expect(entity.city).to eq(subject.entity_city)
        expect(entity.zip).to eq(subject.entity_zip)
      end

      it 'sets the user on the request with the correct email' do
        subject.approve_request
        expect(subject.user).to be_present
        expect(subject.user.email).to eq(subject.email)
      end

      it 'assigns the new entity to the user' do
        subject.approve_request
        expect(subject.user.entity).to eq(Entity.last)
      end

      it 'marks the request as approved and persists it' do
        subject.approve_request
        expect(subject.reload.approved).to be true
      end

      it 'sends the approval mailer asynchronously' do
        subject.approve_request
        expect(ApiSubmitterRequestsMailer)
          .to have_received(:api_submitter_request_approved)
          .with(subject.user)
        expect(mailer_double).to have_received(:deliver_later)
      end
    end

    context 'when no user exists with the request email' do
      it 'creates exactly one new user' do
        expect { subject.approve_request }.to change(User, :count).by(1)
      end

      it 'creates exactly one new entity' do
        expect { subject.approve_request }.to change(Entity, :count).by(1)
      end

      it 'sets the submitter role on the new user' do
        subject.approve_request
        expect(subject.user.roles).to include(Role.submitter)
      end

      it 'sets widget_submissions_forward_email on the new user' do
        subject.approve_request
        expect(subject.user.widget_submissions_forward_email)
          .to eq(subject.submissions_forward_email)
      end

      include_examples 'completes approval'
    end

    context 'when a user already exists with the request email' do
      let!(:existing_user) do
        create(:user, email: 'requester@example.com')
      end

      it 'does not create a new user' do
        expect { subject.approve_request }.not_to change(User, :count)
      end

      it 'creates exactly one new entity' do
        expect { subject.approve_request }.to change(Entity, :count).by(1)
      end

      it 'updates the existing user entity to the newly created entity' do
        subject.approve_request
        expect(existing_user.reload.entity).to eq(Entity.last)
      end

      it 'adds the submitter role to the existing user' do
        subject.approve_request
        expect(existing_user.reload.roles).to include(Role.submitter)
      end

      it 'does not duplicate the submitter role if user already has it' do
        existing_user.update!(roles: [Role.submitter])
        subject.approve_request
        submitter_roles = existing_user.reload.roles.select { |r| r == Role.submitter }
        expect(submitter_roles.count).to eq(1)
      end

      context 'when the existing user has other roles' do
        before { existing_user.update!(roles: [Role.notice_viewer]) }

        it 'preserves existing roles when adding submitter' do
          subject.approve_request
          expect(existing_user.reload.roles).to include(Role.notice_viewer, Role.submitter)
        end
      end

      include_examples 'completes approval'
    end

    context 'when entity creation fails' do
      before do
        allow(Entity).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect { subject.approve_request }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create a user' do
        expect { subject.approve_request rescue nil }.not_to change(User, :count)
      end

      it 'does not mark the request as approved' do
        subject.approve_request rescue nil
        expect(subject.reload.approved).not_to be true
      end

      it 'does not send the mailer' do
        subject.approve_request rescue nil
        expect(ApiSubmitterRequestsMailer)
          .not_to have_received(:api_submitter_request_approved)
      end
    end

    context 'when saving the request fails' do
      before do
        allow(subject).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect { subject.approve_request }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not send the mailer' do
        subject.approve_request rescue nil
        expect(ApiSubmitterRequestsMailer)
          .not_to have_received(:api_submitter_request_approved)
      end
    end
  end
end
