require 'spec_helper'

describe Dmca do
  it { should validate_presence_of :works }
  it { should validate_presence_of :entity_notice_roles }
  it { should ensure_inclusion_of(:language).in_array(Language.codes) }
  it { should ensure_inclusion_of(:action_taken).in_array(Dmca::VALID_ACTIONS).allow_blank }

  context 'automatic validations' do
    it { should ensure_length_of(:title).is_at_most(255) }
  end

  it { should have_many :file_uploads }
  it { should have_many(:entity_notice_roles).dependent(:destroy) }
  it { should have_and_belong_to_many :works }
  it { should have_many(:infringing_urls).through(:works) }
  it { should have_many(:entities).through(:entity_notice_roles)  }
  it { should have_many(:topic_assignments).dependent(:destroy) }
  it { should have_many(:topics).through(:topic_assignments) }
  it { should have_and_belong_to_many :relevant_questions }

  it_behaves_like "an object with a recent scope"
  it_behaves_like "an object tagged in the context of", "tag", case_insensitive: true
  it_behaves_like "an object tagged in the context of", "jurisdiction"

  it "leaves no action taken as unspecified" do
    notice = Dmca.new

    expect(notice.action_taken).to be_nil
  end

  context "entity notice roles" do
    context 'with entities' do
      %w( sender recipient ).each do |role_name|
        context "##{role_name}" do
          it "returns entity of type #{role_name}" do
            entity = create(:entity)
            notice = create(:dmca)

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

    context "without notice roles" do
      it "returns nil for recipient and sender" do
        notice = create(:dmca)
        expect(notice.recipient).to be_nil
        expect(notice.sender).to be_nil
      end
    end
  end

  context "#all_relevant_questions" do
    it "returns questions related to it and its topics" do
      topic1_questions = [create(:relevant_question, question: "Q1")]
      topic2_questions = [
        create(:relevant_question, question: "Q2"),
        create(:relevant_question, question: "Q3")
      ]
      notice_questions = [create(:relevant_question, question: "Q4")]
      notice = create(
        :dmca,
        topics: [
          create(:topic, relevant_questions: topic1_questions),
          create(:topic, relevant_questions: topic2_questions)
        ],
        relevant_questions: notice_questions
      )

      questions = notice.all_relevant_questions.map(&:question)

      expect(questions).to match_array %w( Q1 Q2 Q3 Q4 )
    end

    it "does not duplicate questions" do
      shared_question = create(:relevant_question, question: "Q1")
      topic_questions = [
        shared_question,
        create(:relevant_question, question: "Q2")
      ]
      notice = create(
        :dmca,
        topics: [create(:topic, relevant_questions: topic_questions)],
        relevant_questions: [shared_question]
      )

      questions = notice.all_relevant_questions.map(&:question)

      expect(questions).to match_array %w( Q1 Q2 )
    end

    it "can be limited and is random" do
      notice = create(
        :dmca, relevant_questions: create_list(:relevant_question, 10)
      )

      questions_1 = notice.all_relevant_questions(3)
      questions_2 = notice.all_relevant_questions(3)

      expect(questions_1.length).to eq 3
      expect(questions_2.length).to eq 3
      expect(questions_2.sort).not_to eq questions_1.sort
    end
  end

  context "#related_blog_entries" do
    it "returns blog_entries that share topics with itself" do
      notice = create(:dmca, :with_topics)
      expected_blog_entries = [
        create(:blog_entry, :published, topics: [notice.topics.sample]),
        create(:blog_entry, :published, topics: [notice.topics.sample]),
        create(:blog_entry, :published, topics: [notice.topics.sample])
      ]

      related_blog_entries = notice.related_blog_entries

      expect(related_blog_entries).to match_array(expected_blog_entries)
    end

    it "does not return blog entries with different topics" do
      notice = create(:dmca, :with_topics)
      create(:blog_entry, :published, topics: [create(:topic)])

      related_blog_entries = notice.related_blog_entries

      expect(related_blog_entries).to be_empty
    end

    it "does not duplicate blog entries" do
      notice = create(:dmca, :with_topics)
      blog_entry = create(
        :blog_entry, :published, topics: notice.topics
      )

      related_blog_entries = notice.related_blog_entries

      expect(related_blog_entries).to eq [blog_entry]
    end

    it "returns a limited set of related blog entries" do
      notice = create(:dmca, :with_topics)
      create(:blog_entry, :published, topics: [notice.topics.sample])
      create(:blog_entry, :published, topics: [notice.topics.sample])
      create(:blog_entry, :published, topics: [notice.topics.sample])

      blog_entries = notice.related_blog_entries(2)

      expect(blog_entries.length).to eq 2
    end

    it "returns only published blog entries" do
      notice = create(:dmca, :with_topics)
      expected_blog_entries = [
        create(:blog_entry, :published, topics: [notice.topics.first]),
        create(:blog_entry, :published, topics: [notice.topics.first]),
      ]
      create(:blog_entry, topics: [notice.topics.first])
      create(
        :blog_entry,
        topics: [notice.topics.first],
        published_at: 1.day.from_now
      )
      create(
        :blog_entry,
        topics: [notice.topics.first],
        published_at: 1.hour.from_now
      )

      blog_entries = notice.related_blog_entries

      expect(blog_entries).to match_array(expected_blog_entries)
    end
  end

  context "search index" do
    before do
      tire = double("Tire proxy").as_null_object
      Dmca.any_instance.stub(:tire).and_return(tire)
    end

    it "updates the index after touch" do
      notice = create(:dmca)
      notice.tire.should_receive(:update_index)

      notice.touch
    end

    it "is touched on topic changes" do
      notice = create(:dmca)
      notice.tire.should_receive(:update_index).exactly(3).times

      topic = notice.topics.create!(name: "name 1")
      topic.update_attributes!(name: "name 2")
      topic.destroy
    end

    it "is touched on entity changes" do
      notice = create(:dmca)
      entity = create(:entity)
      notice.tire.should_receive(:update_index).exactly(3).times

      create(
        :entity_notice_role,
        name: 'sender',
        notice: notice,
        entity: entity
      )
      entity.update_attributes!(name: "name 2")
      entity.destroy
    end
  end

  context "#redacted" do
    it "returns '#{Dmca::UNDER_REVIEW_VALUE}' when review is required" do
      notice = Dmca.new(review_required: true, body: "A value")

      expect(notice.redacted(:body)).to eq Dmca::UNDER_REVIEW_VALUE
    end

    it "returns the actual value when review is not required" do
      notice = Dmca.new(review_required: false, body: "A value")

      expect(notice.redacted(:body)).to eq "A value"
    end
  end

  context "#auto_redact" do
    it "calls RedactsNotices#redact on itself" do
      notice = Dmca.new
      redactor = RedactsNotices.new
      redactor.should_receive(:redact).with(notice)
      RedactsNotices.should_receive(:new).and_return(redactor)

      notice.auto_redact
    end
  end

  context "#mark_for_review" do
    it "Sets review_required to true if risk is assessed as high" do
      notice = create(:dmca, review_required: false)
      mock_assessment(notice, true)

      notice.mark_for_review

      expect(notice).to be_review_required
    end

    it "Sets review_required to false if risk is assessed as low" do
      notice = create(:dmca, review_required: true)
      mock_assessment(notice, false)

      notice.mark_for_review

      expect(notice).not_to be_review_required
    end

    def mock_assessment(notice, high_risk)
      assessment = RiskAssessment.new(notice)
      assessment.stub(:high_risk?).and_return(high_risk)

      RiskAssessment.should_receive(:new).with(notice).and_return(assessment)
    end
  end

  context "#next_requiring_review" do
    it "returns the next notice (by id) which requires review" do
      create(:dmca, review_required: true)
      notice = create(:dmca, review_required: true)
      create(:dmca, review_required: false)
      expected_notice = create(:dmca, review_required: true)

      next_notice = notice.next_requiring_review

      expect(next_notice).to eq expected_notice
    end

    it "returns nil when none exist" do
      notice = create(:dmca)

      expect(notice.next_requiring_review).not_to be
    end
  end

  context ".available_for_review" do
    it "returns notices with no reviewer" do
      user = create(:user)
      expected_notices = create_list(:dmca, 2, review_required: true)
      create_list(:dmca, 2, review_required: true, reviewer: user)
      create_list(:dmca, 2, review_required: false)

      notices = Dmca.available_for_review

      expect(notices).to match_array(expected_notices)
    end

    it "omits spam and hidden notices" do
      expected_notices = create_list(:dmca, 2, review_required: true)
      create_list(:dmca, 2, review_required: true, spam: true)
      create_list(:dmca, 2, review_required: true, hidden: true)

      notices = Dmca.available_for_review

      expect(notices).to match_array(expected_notices)

    end
  end

  context ".in_review" do
    it "returns notices in review with that user" do
      user_one, user_two = create_list(:user, 2)
      expected_notices = create_list(
        :dmca, 2, review_required: true, reviewer: user_one
      )
      create_list(:dmca, 2, review_required: true, reviewer: user_two)

      notices = Dmca.in_review(user_one)

      expect(notices).to match_array(expected_notices)
    end
  end

  context ".in_topics" do
    it "returns notices in the given topics" do
      create(:dmca) # not to be found
      expected_notices = create_list(:dmca, 3, :with_topics)
      topics = expected_notices.map(&:topics).flatten

      notices = Dmca.in_topics(topics)

      expect(notices).to match_array(expected_notices)
    end
  end

  context ".submitted_by" do
    it "returns the notices submitted by the given submitters" do
      create(:dmca) # not to be found
      expected_notices = create_list(:dmca, 3, role_names: %w( submitter ))
      submitters = expected_notices.map(&:submitter)

      notices = Dmca.submitted_by(submitters)

      expect(notices).to match_array(expected_notices)
    end
  end

  context "#supporting_documents" do
    it "returns file uploads of kind 'supporting'" do
      file_uploads = [
        build(:file_upload, kind: 'original'),
        build(:file_upload, kind: 'supporting'),
        build(:file_upload, kind: 'supporting'),
      ]

      notice = create(:dmca, file_uploads: file_uploads)

      expect(notice).to have(2).supporting_documents
      expect(notice.supporting_documents).to be_all { |d| d.kind == 'supporting' }
    end
  end

  context "#original_documents" do
    it "returns file uploads of kind 'original'" do
      file_uploads = [
        build(:file_upload, kind: 'supporting'),
        build(:file_upload, kind: 'original'),
        build(:file_upload, kind: 'original'),
      ]

      notice = create(:dmca, file_uploads: file_uploads)

      expect(notice).to have(2).original_documents
      expect(notice.original_documents).to be_all { |d| d.kind == 'original' }
    end
  end

  context ".find_visible" do
    it "finds notices which are not spam or hidden" do
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

end
