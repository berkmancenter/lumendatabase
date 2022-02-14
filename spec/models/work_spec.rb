require 'rails_helper'

RSpec.describe Work, type: :model do
  context '.unknown' do
    it 'provides an unknown work' do
      work = Work.unknown

      expect(work.kind).to eq 'unknown'
      expect(work.description).to eq Work::UNKNOWN_WORK_DESCRIPTION
    end

    it 'returns a consistent result' do
      work1 = Work.unknown
      work2 = Work.unknown

      expect(work1).to eq work2
    end

    it 'can be referenced via config' do
      expect(Work.unknown).to eq Lumen::UNKNOWN_WORK
    end
  end

  context '#kind' do
    it 'auto classifies before saving if kind is not set' do
      work = build(:work)

      notice = create(:dmca, works: [work])

      expect(notice.works.first.kind).to eq 'Unspecified'
    end

    it 'does not auto classify if kind is set' do
      expect_any_instance_of(DeterminesWorkKind).not_to receive(:kind)
      work = build(:work, kind: 'foo')
      create(:dmca, works: [work])
    end
  end

  it 'validates infringing urls correctly when multiple are used at once' do
    notice = notice_with_works_attributes(
      [
        { infringing_urls_attributes: [{ url: 'this is not a url' }] },
        { infringing_urls_attributes: [{ url: 'this is also not a url' }] }
      ]
    )

    expect(notice).not_to be_valid
    expect(notice.errors.messages).to eq(
      'works': ['is invalid']
    )
  end

  it 'validates copyrighted urls correctly when multiple are used at once' do
    notice = notice_with_works_attributes(
      [
        { copyrighted_urls_attributes: [{ url: 'this is not a url' }] },
        { copyrighted_urls_attributes: [{ url: 'this is also not a url' }] }
      ]
    )

    expect(notice).not_to be_valid
    expect(notice.errors.messages).to eq(
      'works': ['is invalid']
    )
  end

  context 'redaction' do
    it 'redacts phone numbers with auto_redact' do
      content = '(617) 867-5309'
      test_redaction(content)
    end

    it 'redacts emails with auto_redact' do
      content = 'me@example.com'
      test_redaction(content)
    end

    it 'redacts SSNs with auto_redact' do
      content = '123-45-6789'
      test_redaction(content)
    end

    it 'redacts automatically on save' do
      params = { description: 'Test' }
      work = Work.new(params)
      notice = create(:dmca, works: [work])
      expect(work).to receive(:auto_redact)
      notice.save
    end
  end

  private

  def notice_with_works_attributes(attributes)
    DMCA.new(
      works_attributes: attributes,
      entity_notice_roles_attributes: [{
        name: 'recipient',
        entity_attributes: { name: 'Recipient' }
      }]
    )
  end

  def work_for_redaction_testing(redact_me)
    params = { description: "Test if we redact #{redact_me}" }
    work = Work.new(params)
    notice = create(:dmca, works: [work])
    notice.save
    notice.reload
    notice.works.first
  end

  def test_redaction(content)
    work = work_for_redaction_testing(content)

    expect(work.description).not_to include content
    expect(work.description_original).to include content
  end
end
