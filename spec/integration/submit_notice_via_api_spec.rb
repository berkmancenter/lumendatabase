require 'rails_helper'
require 'base64'

feature 'notice submission', js: true do
  include CurbHelpers

  scenario 'submitting as an unauthenticated user' do
    parameters = request_hash(default_notice_hash)
    parameters.delete(:authentication_token)

    curb = post_api('/notices', parameters)

    expect(curb.response_code).to eq 401
  end

  scenario 'submitting as a normal user' do
    user = create(:user)
    parameters = request_hash(default_notice_hash, user)

    curb = post_api('/notices', parameters)

    expect(curb.response_code).to eq 401
  end

  scenario 'submitting an incomplete notice' do
    curb = post_api('/notices', request_hash(title: 'foo'))

    expect(curb.response_code).to eq 422
  end

  scenario 'submitting a notice' do
    parameters = request_hash(
      default_notice_hash({
        title: 'A superduper title',
        works_attributes: [{
          description: 'A work',
          infringing_urls_attributes: [{
            url: 'http://example_in.com'
          }],
          copyrighted_urls_attributes: [{
            url: 'http://example_cp.com'
          }]
        }]
      })
    )

    curb = post_api('/notices', parameters)

    expect(curb.response_code).to eq 201

    notice = Notice.last

    expect(notice.title).to eq 'A superduper title'
    expect(notice.recipient.kind).to eq 'individual'
    notice.works.each_with_index do |work, index|
      json_work = notice.works_json[index]
      expect(json_work['description']).to eq work.description
      expect(json_work['infringing_urls'][0]['url']).to eq work.infringing_urls.first.url
      expect(json_work['copyrighted_urls'][0]['url']).to eq work.copyrighted_urls.first.url
    end
  end

  scenario 'submitting a notice with token in header' do
    parameters = request_hash(default_notice_hash)
    token = parameters.delete(:x_authentication_token)

    curb = post_api('/notices', parameters) do |curl|
      curl.headers['X_AUTHENTICATION_TOKEN'] = token
    end

    expect(curb.response_code).to eq 201
  end

  scenario 'submitting a notice with an existing Entity' do
    entity = create(:entity)

    parameters = request_hash(
      default_notice_hash(
        title: 'A notice with an entity created by id',
        entity_notice_roles_attributes: [{
          name: 'recipient',
          entity_id: entity.id
        }]
      )
    )

    curb = post_api('/notices', parameters)

    expect(curb.response_code).to eq 201
    expect(Notice.last.recipient).to eq entity
    expect(Notice.last.title).to eq 'A notice with an entity created by id'
  end

  scenario 'submitting as a user with a linked entity' do
    user = create(:user, :submitter)
    entity = create(:entity, users: [user], name: 'Twitter')
    notice_parameters = default_notice_hash(title: 'A superduper title')
    notice_parameters.delete(:entity_notice_roles_attributes)
    parameters = request_hash(notice_parameters, user)

    curb = post_api('/notices', parameters)

    notice = Notice.last
    expect(curb.response_code).to eq 201
    expect(notice.submitter).to eq entity
    expect(notice.recipient).to eq entity
  end

  scenario 'submitting as a user with a linked entity and providing a submitter entity' do
    user = create(:user, :submitter)
    entity = create(:entity, users: [user], name: 'Twitter')
    notice_parameters = default_notice_hash(
      title: 'A superduper title',
      entity_notice_roles_attributes: [
        {
          name: 'recipient',
          entity_attributes: {
            name: 'The Googs'
          }
        },
        {
          name: 'submitter',
          entity_attributes: {
            name: 'Extra submitter entity will be discarded'
          }
        }
      ]
    )
    parameters = request_hash(notice_parameters, user)

    curb = post_api('/notices', parameters)

    notice = Notice.last
    expect(curb.response_code).to eq 201
    expect(notice.submitter).to eq entity
  end

  scenario 'submitting a notice with text file attachments' do
    parameters = request_hash(notice_hash_with_text_files)

    post_api('/notices', parameters)

    notice = Notice.last
    original_document = original_document_file(notice)
    supporting_document = supporting_document_file(notice)

    expect(file_contents_for(original_document.path)).to eq 'Original Document'
    expect(file_contents_for(supporting_document.path))
      .to eq 'Supporting Document'

    expect(original_document.original_filename).to eq 'original_document.txt'
    expect(supporting_document.original_filename)
      .to eq 'supporting_document.txt'
  end

  scenario 'submitting a notice with binary file attachments' do
    parameters = request_hash(notice_hash_with_binary_files)

    post_api('/notices', parameters)

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

  context 'concatenation' do
    scenario 'submitting concatenated copyrighted URLs' do
      parameters = request_hash(
        default_notice_hash(
          works_attributes: [{
            description: 'A work',
            copyrighted_urls_attributes: [{
              url: 'http://example.com/http://example2.com'
            }]
          }]
        )
      )

      curb = post_api('/notices', parameters)

      expect(curb.response_code).to eq 201

      work = Notice.last.works.first

      expect(work.copyrighted_urls.map(&:url)).to match_array([
        'http://example.com/', 'http://example2.com'
      ])
    end

    scenario 'submitting both valid and concatenated copyrighted URLs' do
      parameters = request_hash(
        default_notice_hash(
          works_attributes: [{
            description: 'A work',
            copyrighted_urls_attributes: [
              { url: 'http://example.com/http://example2.com' },
              { url: 'http://picklefactory.com' }
            ]
          }]
        )
      )

      curb = post_api('/notices', parameters)

      expect(curb.response_code).to eq 201

      work = Notice.last.works.first

      expect(work.copyrighted_urls.map(&:url)).to match_array([
        'http://example.com/', 'http://example2.com', 'http://picklefactory.com'
      ])
    end

    scenario 'submitting concatenated infringing URLs' do
      parameters = request_hash(
        default_notice_hash(
          works_attributes: [{
            description: 'A work',
            infringing_urls_attributes: [{
              url: 'http://example.com/http://example2.com'
            }]
          }]
        )
      )

      curb = post_api('/notices', parameters)

      expect(curb.response_code).to eq 201

      work = Notice.last.works.first

      expect(work.infringing_urls.map(&:url)).to match_array([
        'http://example.com/', 'http://example2.com'
      ])
    end

    # This is to protect against a bug we saw in the wild, introduced by the
    # deconcatenation work.
    scenario "submitting URLs which look concatenated but aren't" do
      parameters = request_hash(
        default_notice_hash(
          works_attributes: [{
            description: 'A work',
            infringing_urls_attributes: [{
              url: 'http://httpwww.mp3stahuj.cz/henry-d-feat-sista-carmen-prague-city-42689'
            }]
          }]
        )
      )

      curb = post_api('/notices', parameters)

      expect(curb.response_code).to eq 201

      work = Notice.last.works.first

      expect(work.infringing_urls.map(&:url)).to match_array([
        'http://httpwww.mp3stahuj.cz/henry-d-feat-sista-carmen-prague-city-42689'
      ])
    end
  end

  scenario 'submitting a notice with null bytes' do
    parameters = request_hash(
      default_notice_hash({
        title: 'A superduper\u0000 title'
      })
    )

    curb = post_api('/notices', parameters)

    expect(curb.response_code).to eq 400
  end

  context 'redacting defamations' do
    scenario 'sender name is redacted if there is no principal provided' do
      original_text = <<-BODY
        My name is Tonny Bastet, do something please!!!
      BODY
      redacted_text = <<-BODY
        My name is [REDACTED], do something please!!!
      BODY
      original_infringing_url = 'http://disney.com/tonny_bastet.mp4'
      redacted_infringing_url = 'http://disney.com/[REDACTED].mp4'

      parameters = request_hash(
        default_notice_hash(
          type: 'Defamation',
          body: original_text,
          entity_notice_roles_attributes: [
            {
              name: 'recipient',
              entity_attributes: {
                name: 'The Googs'
              }
            },
            {
              name: 'sender',
              entity_attributes: {
                name: 'Tonny Bastet'
              }
            }
          ],
          works_attributes: [
            {
              description: original_text,
              infringing_urls_attributes: [
                {
                  url: original_infringing_url
                }
              ]
            }
          ]
        )
      )

      submit_and_test_defamation_redaction(parameters, original_text, redacted_text, original_infringing_url, redacted_infringing_url)
    end

    scenario 'principal name is redacted if there is principal provided' do
      original_text = <<-BODY
        My name not John Bastet, it's Tonny Kokosh, do something please!!!
      BODY
      redacted_text = <<-BODY
        My name not John Bastet, it's [REDACTED], do something please!!!
      BODY
      original_infringing_url = 'http://disney.com/tonny_kokosh.mp4'
      redacted_infringing_url = 'http://disney.com/[REDACTED].mp4'

      parameters = request_hash(
        default_notice_hash(
          type: 'Defamation',
          body: original_text,
          entity_notice_roles_attributes: [
            {
              name: 'recipient',
              entity_attributes: {
                name: 'The Googs'
              }
            },
            {
              name: 'sender',
              entity_attributes: {
                name: 'John Bastet'
              }
            },
            {
              name: 'principal',
              entity_attributes: {
                name: 'Tonny Kokosh'
              }
            }
          ],
          works_attributes: [
            {
              description: original_text,
              infringing_urls_attributes: [
                {
                  url: original_infringing_url
                }
              ]
            }
          ]
        )
      )

      submit_and_test_defamation_redaction(parameters, original_text, redacted_text, original_infringing_url, redacted_infringing_url)
    end
  end

  scenario 'submitting problamatic urls' do
    works_url_1 = [
      {
        description: 'Heyo',
        infringing_urls_attributes: [
          {
            url: 'https://www.google.com/maps/place/WW+AUTO/@43.7808951,4.2929117,15z/data=!4m6!3m5!1s0x12b4293642723a93:0xa720e27e0e9f38fc!8m2!3d43.7808951!4d4.2929117!16s%2Fg%2F11gzq2dnz5?entry=ttu'
          }
        ]
      }
    ]

    parameters = request_hash(default_notice_hash({
      type: 'Defamation',
      works_attributes: works_url_1
    }))

    curb = post_api('/notices', parameters)

    expect(curb.response_code).to eq 201
  end

  context 'redacting Google TLD-only URLs' do
    scenario 'redacts single-letter as well as multi-letter domains' do
      parameters = request_hash(
        default_notice_hash(
          type: 'Defamation',
          entity_notice_roles_attributes: [
            {
              name: 'submitter',
              entity_attributes: { name: 'Google LLC' }
            },
            {
              name: 'recipient',
              entity_attributes: { name: 'Google LLC' }
            },
            {
              name: 'sender',
              entity_attributes: { name: 'Tonny Bastet' }
            }
          ],
          works_attributes: [
            {
              description: 'Test',
              infringing_urls_attributes: [
                { url: 'http://example.com' },
                { url: 'http://x.io' },
                { url: 'http://www.example.com' },
                { url: 'http://single.org/page' },
                { url: 'http://single.org/' },
                { url: 'http://single.co.uk/' }
              ]
            }
          ]
        )
      )

      post_api('/notices', parameters)
      notice = Notice.last
      urls = notice.works.first.infringing_urls.map(&:url)

      expect(urls[0]).to eq('http://e[redacted]e.com')
      expect(urls[1]).to eq('http://x[redacted].io')
      expect(urls[2]).to eq('http://www.e[redacted]e.com')
      expect(urls[3]).to eq('http://single.org/page')
      expect(urls[4]).to eq('http://s[redacted]e.org')
      expect(urls[5]).to eq('http://s[redacted]e.co.uk')
    end
  end

  private

  def original_document_file(notice)
    notice.original_documents.first.file
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
    default_notice_hash(
      file_uploads_attributes: [{
        kind: 'original',
        file: data_uri_for('text/plain', 'Original Document'),
        file_name: 'original_document.txt'
      }, {
        kind: 'supporting',
        file: data_uri_for('text/plain', 'Supporting Document'),
        file_name: 'supporting_document.txt'
      }]
    )
  end

  def notice_hash_with_binary_files
    default_notice_hash(
      file_uploads_attributes: [{
        kind: 'original',
        file: data_uri_for('image/jpg',
                           file_contents_for(
                             'spec/support/example_files/original.jpg'
                           )),
        file_name: 'original.jpg'
      }, {
        kind: 'supporting',
        file: data_uri_for('image/jpg',
                           file_contents_for(
                             'spec/support/example_files/supporting.jpg'
                           )),
        file_name: 'supporting.jpg'
      }]
    )
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

  def request_hash(notice_hash, user = create(:user, :submitter))
    {
      notice: notice_hash,
      authentication_token: user.authentication_token
    }
  end

  def submit_and_test_defamation_redaction(parameters, original_text, redacted_text, original_infringing_url, redacted_infringing_url)
    post_api('/notices', parameters)

    notice = Notice.last

    expect(notice.body).to eq redacted_text
    expect(notice.body_original).to eq original_text
    expect(notice.works.first.description).to eq redacted_text
    expect(notice.works.first.description_original).to eq original_text
    expect(notice.works.first.infringing_urls.first.url).to eq redacted_infringing_url
    expect(notice.works.first.infringing_urls.first.url_original).to eq original_infringing_url
  end
end
