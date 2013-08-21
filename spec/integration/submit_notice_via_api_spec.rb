require 'spec_helper'
require 'base64'

feature "notice submission" do
  include CurbHelpers

  scenario "submitting an incomplete notice", js: true do
    with_curb_post_for_json('notices','{"notice": {"title": "foo" } }') do |curb_response|
      expect(curb_response.response_code).to eq 422
    end
  end

  scenario "submitting a notice", js: true do
    notice_hash = default_notice_hash(title: 'A superduper title')

    with_curb_post_for_json('notices', request_hash(notice_hash).to_json) do |curb_response|
      expect(curb_response.response_code).to eq 201
      expect(Notice.last.title).to eq 'A superduper title'
    end
  end

  scenario "submitting a notice with an existing Entity", js: true do
    entity = create(:entity)

    notice_hash = default_notice_hash(
      title: 'A notice with an entity created by id',
      entity_notice_roles_attributes: [
        {
          name: 'recipient',
          entity_id: entity.id
        }
      ]
    )

    with_curb_post_for_json('notices', request_hash(notice_hash).to_json) do |curb_response|
      expect(curb_response.response_code).to eq 201
      expect(Notice.last.recipient).to eq entity
      expect(Notice.last.title).to eq 'A notice with an entity created by id'
    end
  end

  scenario "submitting a notice with text file attachments", js: true do
    notice_hash = notice_hash_with_text_files
    with_curb_post_for_json('notices', request_hash(notice_hash).to_json) do |curb_response|
      notice = Notice.last
      original_document = original_document_file(notice)
      supporting_document = supporting_document_file(notice)

      expect(file_contents_for(original_document.path)).to eq 'Original Document'
      expect(file_contents_for(supporting_document.path)).to eq 'Supporting Document'

      expect(original_document.original_filename).to eq 'original_document.txt'
      expect(supporting_document.original_filename).to eq 'supporting_document.txt'
    end
  end

  scenario "submitting a notice with binary file attachments", js: true do
    notice_hash = notice_hash_with_binary_files
    with_curb_post_for_json('notices', request_hash(notice_hash).to_json) do |curb_response|
      notice = Notice.last
      original_document = original_document_file(notice)
      supporting_document = supporting_document_file(notice)

      expect(file_contents_for(original_document.path)).to eq(
        file_contents_for('spec/support/example_files/original.jpg')
      )
      expect(file_contents_for(supporting_document.path)).to eq(
        file_contents_for('spec/support/example_files/supporting.jpg')
      )

      expect(original_document.original_filename).to eq 'original.jpg'
      expect(supporting_document.original_filename).to eq 'supporting.jpg'
    end
  end
end

def original_document_file(notice)
  notice.file_uploads.where(kind: 'original').first.file
end

def supporting_document_file(notice)
  notice.supporting_documents.first.file
end

def file_contents_for(path)
  File.read(path)
end

def data_uri_for(mime_type, data)
  "data:#{mime_type};base64,#{Base64.encode64(data).rstrip}"
end

def notice_hash_with_text_files
  default_notice_hash.merge!(
    file_uploads_attributes: [
      {
        kind: 'original',
        file: data_uri_for('text/plain','Original Document'),
        file_name: 'original_document.txt',
      },
      {
        kind: 'supporting',
        file: data_uri_for('text/plain','Supporting Document'),
        file_name: 'supporting_document.txt',
      }
    ]
  )
end

def notice_hash_with_binary_files
  default_notice_hash.merge!(
    file_uploads_attributes: [
      {
        kind: 'original',
        file: data_uri_for('image/jpg',file_contents_for('spec/support/example_files/original.jpg')),
        file_name: 'original.jpg',
      },
      {
        kind: 'supporting',
        file: data_uri_for('image/jpg',file_contents_for('spec/support/example_files/supporting.jpg')),
        file_name: 'supporting.jpg',
      },
    ]
  )
end

def default_notice_hash(opts = {})
  {
    title: 'A sweet title',
    works_attributes:
    [
      {
        description: 'A work'
      }
    ],
    entity_notice_roles_attributes:
    [
      {
        name: 'recipient',
        entity_attributes: {
          name: 'The Googs'
        }
      }
    ]
  }.merge!(opts)
end

def request_hash(notice_hash)
  {
    notice: notice_hash
  }
end
