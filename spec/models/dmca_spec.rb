require 'rails_helper'

describe DMCA, type: :model do
  before do
    @notice_topics = create_list(:notice_topic, 8)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Validations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  it { is_expected.to validate_presence_of :works }
  it { is_expected.to validate_presence_of :entity_notice_roles }
  it {
    is_expected.to validate_inclusion_of(:language).in_array(Language.codes)
  }
  it {
    is_expected.to validate_inclusion_of(:action_taken)
      .in_array(DMCA::VALID_ACTIONS)
      .allow_blank
  }

  context 'automatic validations' do
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Model definition ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  it { is_expected.to have_many :file_uploads }
  it { is_expected.to have_many(:entity_notice_roles).dependent(:destroy) }
  it { is_expected.to have_and_belong_to_many :works }
  it { is_expected.to have_many(:infringing_urls).through(:works) }
  it { is_expected.to have_many(:entities).through(:entity_notice_roles) }
  it { is_expected.to have_many(:topic_assignments).dependent(:destroy) }
  it { is_expected.to have_many(:topics).through(:topic_assignments) }
  it { is_expected.to have_and_belong_to_many :relevant_questions }
  it { is_expected.to have_one :documents_update_notification_notice }

  it_behaves_like 'an object with a recent scope'
  it_behaves_like 'an object tagged in the context of',
                  'tag', case_insensitive: true
  it_behaves_like 'an object tagged in the context of', 'jurisdiction'

  it 'leaves no action taken as unspecified' do
    notice = DMCA.new

    expect(notice.action_taken).to be_nil
  end

  it 'has the expected partial path' do
    notice = create(:dmca)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Misc contexts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  context 'entity notice roles' do
    it 'has the expected entity notice roles' do
      expected = %w[recipient sender principal submitter]
      expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES)
        .to match_array expected
    end

    it 'sets the default kind of entities' do
      notice = create(:dmca, role_names: %w[sender principal])

      expect(notice.principal.kind).to eq('individual')
      expect(notice.sender.kind).to eq('individual')
    end

    context 'with entities' do
      described_class::DEFAULT_ENTITY_NOTICE_ROLES.each do |role_name|
        context "##{role_name}" do
          it "returns entity of type #{role_name}" do
            # note: must use role names we're not testing in the factory
            # call, otherwise extra entities can fail the test.
            notice = create(:dmca, role_names: %w[agent])
            entity = create(:entity)
            create(
              :entity_notice_role,
              entity: entity,
              notice: notice,
              name: role_name
            )

            expect(notice.send(role_name)).to eq entity
          end
        end
      end
    end

    context 'without notice roles' do
      it 'returns nil for recipient and sender' do
        notice = create(:dmca)
        expect(notice.recipient).to be_nil
        expect(notice.sender).to be_nil
      end
    end
  end

  context '.in_topics' do
    it 'returns notices in the given topics' do
      _single = create(:dmca) # not to be found
      topics = create_list(:topic, 3)
      expected_notices = [
        create(:dmca, topics: topics),
        create(:dmca, topics: topics)
      ]

      notices = DMCA.in_topics(topics)

      expect(notices).to match_array(expected_notices)
    end
  end

  context '.submitted_by' do
    it 'returns the notices submitted by the given submitters' do
      create(:dmca) # not to be found
      expected_notices = create_list(:dmca, 3, role_names: %w[submitter])
      submitters = expected_notices.map(&:submitter)

      notices = DMCA.submitted_by(submitters)

      expect(notices).to match_array(expected_notices)
    end
  end

  context '.find_visible' do
    it 'finds notices which are not spam or hidden' do
      notice = create(:dmca, spam: false)
      spam_notice = create(:dmca, spam: true)
      hidden_notice = create(:dmca, hidden: true)

      expect(Notice.find_visible(notice.id)).to eq notice
      expect { Notice.find_visible(spam_notice.id) }.to raise_error(
        ActiveRecord::RecordNotFound
      )
      expect { Notice.find_visible(hidden_notice.id) }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end
  end

  context '#on_behalf_of_principal?' do
    it 'returns true when principal is present and differs from sender' do
      notice = create(:dmca, role_names: %w[sender principal])
      notice.sender.update_attributes(name: 'The Sender')
      notice.principal.update_attributes(name: 'The Principal')

      expect(notice).to be_on_behalf_of_principal
    end

    it 'returns false when principal is not present' do
      notice = create(:dmca, role_names: %w[sender principal])
      notice.sender.update_attributes(name: 'The Sender')
      notice.principal.update_attributes(name: '')

      expect(notice).not_to be_on_behalf_of_principal
    end

    it 'returns false when principal is same as sender' do
      notice = create(:dmca, role_names: %w[sender principal])
      notice.sender.update_attributes(name: 'The Sender')
      notice.principal.update_attributes(name: 'The Sender')

      expect(notice).not_to be_on_behalf_of_principal
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Redaction ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  context '#redacted' do
    it "returns '#{DMCA::UNDER_REVIEW_VALUE}' when review is required" do
      notice = DMCA.new(review_required: true, body: 'A value')

      expect(notice.redacted(:body)).to eq DMCA::UNDER_REVIEW_VALUE
    end

    it 'returns the actual value when review is not required' do
      notice = DMCA.new(review_required: false, body: 'A value')

      expect(notice.redacted(:body)).to eq 'A value'
    end
  end

  context '#auto_redact' do
    it 'calls InstanceRedactor#redact on itself' do
      notice = DMCA.new
      redactor = InstanceRedactor.new
      expect(redactor).to receive(:redact).with(notice)
      expect(InstanceRedactor).to receive(:new).and_return(redactor)

      notice.auto_redact
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Review ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  context '#mark_for_review' do
    it 'Sets review_required to true if risk is assessed as high' do
      notice = create(:dmca, review_required: false)
      mock_assessment(notice, true)

      notice.mark_for_review

      expect(notice).to be_review_required
    end

    it 'Sets review_required to false if risk is assessed as low' do
      notice = create(:dmca, review_required: true)
      mock_assessment(notice, false)

      notice.mark_for_review

      expect(notice).not_to be_review_required
    end

    def mock_assessment(notice, high_risk)
      assessment = RiskAssessment.new(notice)
      allow(assessment).to receive(:high_risk?).and_return(high_risk)

      expect(RiskAssessment).to receive(:new)
        .with(notice)
        .and_return(assessment)
    end
  end

  context '#next_requiring_review' do
    it 'returns the next notice (by id) which requires review' do
      create(:dmca, review_required: true)
      notice = create(:dmca, review_required: true)
      create(:dmca, review_required: false)
      expected_notice = create(:dmca, review_required: true)

      next_notice = notice.next_requiring_review

      expect(next_notice).to eq expected_notice
    end

    it 'returns nil when none exist' do
      notice = create(:dmca)

      expect(notice.next_requiring_review).not_to be
    end
  end

  context '.available_for_review' do
    it 'returns notices with no reviewer' do
      user = create(:user)
      expected_notices = create_list(:dmca, 2, review_required: true)
      create_list(:dmca, 2, review_required: true, reviewer: user)
      create_list(:dmca, 2, review_required: false)

      notices = DMCA.available_for_review

      expect(notices).to match_array(expected_notices)
    end

    it 'omits spam and hidden notices' do
      expected_notices = create_list(:dmca, 2, review_required: true)
      create_list(:dmca, 2, review_required: true, spam: true)
      create_list(:dmca, 2, review_required: true, hidden: true)

      notices = DMCA.available_for_review

      expect(notices).to match_array(expected_notices)
    end
  end

  context '.in_review' do
    it 'returns notices in review with that user' do
      user_one, user_two = create_list(:user, 2)
      expected_notices = create_list(
        :dmca, 2, review_required: true, reviewer: user_one
      )
      create_list(:dmca, 2, review_required: true, reviewer: user_two)

      notices = DMCA.in_review(user_one)

      expect(notices).to match_array(expected_notices)
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ File attachments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  context '#supporting_documents' do
    it "returns file uploads of kind 'supporting'" do
      file_uploads = [
        build(:file_upload, kind: 'original'),
        build(:file_upload, kind: 'supporting'),
        build(:file_upload, kind: 'supporting')
      ]

      notice = create(:dmca, file_uploads: file_uploads)

      expect(notice).to have(2).supporting_documents

      expect(notice.supporting_documents).to(
        be_all { |d| d.kind == 'supporting' }
      )
    end
  end

  context '#original_documents' do
    it "returns file uploads of kind 'original'" do
      file_uploads = [
        build(:file_upload, kind: 'supporting'),
        build(:file_upload, kind: 'original'),
        build(:file_upload, kind: 'original')
      ]

      notice = create(:dmca, file_uploads: file_uploads)

      expect(notice).to have(2).original_documents

      expect(notice.original_documents).to(
        be_all { |d| d.kind == 'original' }
      )
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~ Publication workflows ~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  context '#publication_delay' do
    it "returns 0 if submitter doesn't respond" do
      notice = create(:dmca)

      expect(notice.publication_delay).to eq(0)
    end

    it "returns the submitter's value" do
      notice = create(:dmca)
      user = create(:user, :submitter, :with_entity, publication_delay: 60)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save

      expect(notice.publication_delay).to eq(60)
    end
  end

  context '#should_be_published?' do
    it "returns true if the submitter's publication delay has passed since creation" do
      notice = create(:dmca, created_at: Time.now - 70.seconds)
      user = create(:user, :submitter, :with_entity, publication_delay: 60)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save

      expect(notice.should_be_published?).to be true
    end

    it "returns false if the submitter's publication delay has not passed" do
      notice = create(:dmca, created_at: Time.now - 50.seconds)
      user = create(:user, :submitter, :with_entity, publication_delay: 60)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save

      expect(notice.should_be_published?).to be false
    end

    it "returns true if the submitter's publication delay is 0 seconds" do
      notice = create(:dmca)
      user = create(:user, :submitter, :with_entity)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save

      expect(notice.should_be_published?).to be true
    end
  end

  context '#time_to_publish' do
    it "returns the time of notice creation plus the submitter's publication delay" do
      notice = create(:dmca, created_at: Time.now - 50.seconds)
      user = create(:user, :submitter, :with_entity, publication_delay: 60)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save

      expected_time = notice.created_at + user.publication_delay.seconds
      expect(notice.time_to_publish).to eq expected_time

      notice = create(:dmca)
      user = create(:user, :submitter, :with_entity)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save

      expect(notice.time_to_publish).to eq notice.created_at
    end
  end

  context 'published status' do
    it 'sets the notice to published on creation if it should be published' do
      notice = build(:dmca)
      user = create(:user, :submitter, :with_entity)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save
      notice.save

      expect(notice.submitter).to be_an(Entity)
      expect(notice.published).to be true
    end

    it 'sets the notice to unpublished on creation if it should not be published' do
      notice = build(:dmca)
      user = create(:user, :submitter, :with_entity, publication_delay: 60)
      role = notice.entity_notice_roles.build(name: 'submitter')
      role.entity = user.entity
      role.save
      notice.save

      expect(notice.submitter).to be_an(Entity)
      expect(notice.published).to be false
    end
  end
end
