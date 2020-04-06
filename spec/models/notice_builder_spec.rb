require 'rails_helper'

RSpec.describe NoticeBuilder, type: :model do
  it 'builds an entity of the expected class' do
    n = NoticeBuilder.new(CourtOrder, default_notice_hash).build
    expect(n.class).to eq CourtOrder
  end

  it 'does not save the notice' do
    expect(NoticeBuilder.new(CourtOrder, default_notice_hash).build.persisted?).to be false
  end

  it 'sets a default title' do
    n = NoticeBuilder.new(CourtOrder, default_notice_hash(title: '')).build
    expect(n.title).to be_present
  end

  it 'preserves non-default titles' do
    title = 'Not default'
    n = NoticeBuilder.new(CourtOrder, default_notice_hash(title: title)).build
    expect(n.title).to eq title
  end

  it 'sets file kind to supporting if unset' do
    attrs = file_uploads_attributes
    attrs[0].delete(:kind)
    n = NoticeBuilder.new(
      CourtOrder, default_notice_hash(file_uploads_attributes: attrs)
    ).build
    expect(n.file_uploads.size).to eq 1
    expect(n.file_uploads.first.kind).to eq 'supporting'
  end

  it 'leaves set file types alone' do
    attrs = file_uploads_attributes
    attrs[0][:kind] = 'original'
    n = NoticeBuilder.new(
      CourtOrder, default_notice_hash(file_uploads_attributes: attrs)
    ).build
    expect(n.file_uploads.size).to eq 1
    expect(n.file_uploads.first.kind).to eq 'original'
  end

  it 'redacts' do
    n = NoticeBuilder.new(
      CourtOrder, default_notice_hash(body: 'SSN equals 123-45-6789')
    ).build
    expect(n.body).not_to include '123-45-6789'
  end

  it 'sets submitter if unset' do
    user = create(:user, :with_entity)
    n = NoticeBuilder.new(CourtOrder, default_notice_hash, user).build

    # We must persist this for the implied db call in n.submitter to work.
    n.save
    expect(n.submitter).to eq user.entity
  end

  it 'leaves existing submitters alone' do
    user = create(:user, :with_entity)
    enr = default_notice_hash[:entity_notice_roles_attributes]
    enr[0][:name] = 'submitter'

    n = NoticeBuilder.new(
      CourtOrder,
      default_notice_hash(entity_notice_roles_attributes: enr),
      user
    ).build
    n.save

    assert user.entity.name != 'The Googs'
    expect(n.submitter.name).to eq 'The Googs'
  end

  it 'sets recipient if unset' do
    user = create(:user, :with_entity)
    n = NoticeBuilder.new(
      CourtOrder,
      default_notice_hash(entity_notice_roles_attributes: []),
      user
    ).build

    # We must persist this for the implied db call in n.submitter to work.
    n.save
    expect(n.recipient).to eq user.entity
  end

  it 'leaves existing recipients alone' do
    user = create(:user, :with_entity)

    n = NoticeBuilder.new(CourtOrder, default_notice_hash, user).build
    n.save

    assert user.entity.name != 'The Googs'
    expect(n.recipient.name).to eq 'The Googs'
  end

  def default_notice_hash(options = {})
    {
      title: 'A sweet title',
      works_attributes: [{ description: 'A work' }],
      entity_notice_roles_attributes: [{
        name: 'recipient',
        entity_attributes: {
          name: 'The Googs'
        }
      }]
    }.merge(options)
  end

  def file_uploads_attributes(options = {})
    [{
      kind: 'original',
      file: data_uri_for('text/plain', 'Original Document'),
      file_name: 'original_document.txt'
    }.merge(options)]
  end

  def data_uri_for(mime_type, data)
    "data:#{mime_type};base64,#{Base64.encode64(data).rstrip}"
  end
end
