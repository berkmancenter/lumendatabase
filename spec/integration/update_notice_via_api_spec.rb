require 'rails_helper'
require 'base64'

feature 'notice update via api', js: true do
  include CurbHelpers

  before(:each) do
    @user = create(:user, :submitter)
    @submitter_notice = create_notice(@user)
  end

  scenario 'updating as an unauthenticated user' do
    parameters = request_hash(default_notice_hash)
    parameters.delete(:authentication_token)

    curb = put_api(notice_path(@submitter_notice), parameters)

    expect(curb.response_code).to eq 401
  end

  scenario 'updating as a normal user' do
    normal_user = create(:user)
    parameters = request_hash(default_notice_hash, normal_user)

    curb = put_api(notice_path(@submitter_notice), parameters)

    expect(curb.response_code).to eq 401
  end

  scenario 'updating a notice of a different user' do
    create_notice
    parameters = request_hash(default_notice_hash, @user)

    curb = put_api(notice_path(Notice.last), parameters)

    expect(curb.response_code).to eq 401
  end

  scenario 'updating an incomplete notice' do
    parameters = request_hash({ title: 'foo' }, @user)

    curb = put_api(notice_path(@submitter_notice), parameters)

    expect(curb.response_code).to eq 422
  end

  scenario 'updating a notice' do
    parameters = request_hash(
      default_notice_hash(title: 'A superduper title X'),
      @user
    )

    curb = put_api(notice_path(@submitter_notice), parameters)

    expect(curb.response_code).to eq 200

    notice = Notice.last

    expect(notice.title).to eq 'A superduper title X'
  end

  scenario 'updating a notice with token in header' do
    parameters = request_hash(default_notice_hash, @user)
    token = parameters.delete(:x_authentication_token)

    curb = put_api(notice_path(@submitter_notice), parameters) do |curl|
      curl.headers['X_AUTHENTICATION_TOKEN'] = token
    end

    expect(curb.response_code).to eq 200
  end

  scenario 'updating a notice with an existing Entity' do
    entity = create(:entity)

    parameters = request_hash(
      default_notice_hash(
        title: 'A notice with an entity created by id X',
        entity_notice_roles_attributes: [{
          name: 'recipient',
          entity_id: entity.id
        }]
      ),
      @user
    )

    curb = put_api(notice_path(@submitter_notice), parameters)

    expect(curb.response_code).to eq 200
    expect(Notice.last.recipient).to eq entity
    expect(Notice.last.title).to eq 'A notice with an entity created by id X'
  end

  scenario 'updating a notice with text file attachments' do
    parameters = request_hash(notice_hash_with_text_files, @user)

    put_api(notice_path(@submitter_notice), parameters)

    original_document = original_document_file(@submitter_notice)
    supporting_document = supporting_document_file(@submitter_notice)

    expect(file_contents_for(original_document.path)).to eq 'Original Document'
    expect(file_contents_for(supporting_document.path))
      .to eq 'Supporting Document'

    expect(original_document.original_filename).to eq 'original_document.txt'
    expect(supporting_document.original_filename)
      .to eq 'supporting_document.txt'
  end

  scenario 'submitting a notice with binary file attachments' do
    parameters = request_hash(notice_hash_with_binary_files, @user)

    put_api(notice_path(@submitter_notice), parameters)

    original_document = original_document_file(@submitter_notice)
    supporting_document = supporting_document_file(@submitter_notice)

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
        ),
        @user
      )

      curb = put_api(notice_path(@submitter_notice), parameters)

      expect(curb.response_code).to eq 200

      work = @submitter_notice.works.first

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
        ),
        @user
      )

      curb = put_api(notice_path(@submitter_notice), parameters)

      expect(curb.response_code).to eq 200

      work = @submitter_notice.works.first

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
        ),
        @user
      )

      curb = put_api(notice_path(@submitter_notice), parameters)

      expect(curb.response_code).to eq 200

      work = @submitter_notice.works.first

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
        ),
        @user
      )

      curb = put_api(notice_path(@submitter_notice), parameters)

      expect(curb.response_code).to eq 200

      work = @submitter_notice.works.first

      expect(work.infringing_urls.map(&:url)).to match_array([
        'http://httpwww.mp3stahuj.cz/henry-d-feat-sista-carmen-prague-city-42689'
      ])
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

  def create_notice(user = create(:user, :submitter))
    parameters = request_hash(
      default_notice_hash(title: 'A superduper title'),
      user
    )

    post_api('/notices', parameters)

    Notice.last
  end
end
