require 'spec_helper'

describe Notice do
  context 'schema_validations' do
    it { should validate_presence_of :title }
    it { should ensure_length_of(:title).is_at_most(255) }
  end

  it { should have_many :file_uploads }
  it { should have_many :entity_notice_roles }
  it { should have_and_belong_to_many :works }
  it { should have_many(:infringing_urls).through(:works) }
  it { should have_many(:entities).through(:entity_notice_roles)  }
  it { should have_and_belong_to_many :categories }
  it { should have_and_belong_to_many :relevant_questions }

  context ".recent" do
    it "returns a limited number of notices" do
      create_list(:notice, Notice::RECENT_LIMIT + 1)

      expect(Notice.recent.size).to eq Notice::RECENT_LIMIT
    end

    it "returns notices in descending created_at sent order" do
      third_notice = Timecop.travel(16.hours.ago) { create(:notice) }
      first_notice = Timecop.travel(1.hour.ago) { create(:notice) }
      second_notice = Timecop.travel(10.hours.ago) { create(:notice) }

      expect(Notice.recent).to eq [first_notice, second_notice, third_notice]
    end
  end

  context "tagging" do
    it "accepts a comma-delimited string and turns it into an array of tags" do
      notice = create(:notice, tag_list: 'foo, bar, baz, blee')

      expect(notice.tag_list).to eq ['foo','bar','baz','blee']
    end

    it "has lowercased tags automatically" do
      notice = create(:notice, tag_list: 'FOO')

      expect(notice.tag_list).to eq ['foo']
    end

    it "cleans up unused tags after deletion" do
      notice = create(:notice, tag_list: 'foo')
      notice.tag_list.remove('foo')
      notice.save

      expect(ActsAsTaggableOn::Tag.find_by_name('foo')).not_to be
    end
  end

  context "entity notice roles" do
    it "clean up notice roles after a notice is destroyed" do
      entity = create(:entity_with_notice_roles)
      notice = entity.notices.first

      EntityNoticeRole.any_instance.should_receive(:destroy)
      notice.destroy
    end

    context 'with entities' do
      it "has submitters" do
        notice = create(
          :notice, :with_entities, roles_for_entities: ['submitter']
        )
        expect(notice.submitter).to be_instance_of(Entity)
        expect(notice.submitter).to eq entity_for_role_from_notice(notice, 'submitter')
      end

      it "has recipients" do
        notice = create(
          :notice, :with_entities, roles_for_entities: ['recipient']
        )
        expect(notice.recipient).to be_instance_of(Entity)
        expect(notice.recipient).to eq entity_for_role_from_notice(notice, 'recipient')
      end
    end

    context "without notice roles" do
      it "returns nil for recipient and submitter" do
        notice = create(:notice)
        expect(notice.recipient).to be_nil
        expect(notice.submitter).to be_nil
      end
    end
  end

  context "#all_relevant_questions" do
    it "returns questions related to it and its categories" do
      category1_questions = [create(:relevant_question, question: "Q1")]
      category2_questions = [
        create(:relevant_question, question: "Q2"),
        create(:relevant_question, question: "Q3")
      ]
      notice_questions = [create(:relevant_question, question: "Q4")]
      notice = create(
        :notice,
        categories: [
          create(:category, relevant_questions: category1_questions),
          create(:category, relevant_questions: category2_questions)
        ],
        relevant_questions: notice_questions
      )

      questions = notice.all_relevant_questions.map(&:question)

      expect(questions).to match_array %w( Q1 Q2 Q3 Q4 )
    end

    it "does not duplicate questions" do
      shared_question = create(:relevant_question, question: "Q1")
      category_questions = [
        shared_question,
        create(:relevant_question, question: "Q2")
      ]
      notice = create(
        :notice,
        categories: [create(:category, relevant_questions: category_questions)],
        relevant_questions: [shared_question]
      )

      questions = notice.all_relevant_questions.map(&:question)

      expect(questions).to match_array %w( Q1 Q2 )
    end
  end

  def entity_for_role_from_notice(notice, role)
    notice.entity_notice_roles.where(name: role).first.entity
  end
end
