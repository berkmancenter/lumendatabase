require 'rails_helper'

describe 'notices/show.html.erb' do
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(view.controller).to receive(:current_ability) { @ability }
  end

  it 'displays a metadata from a notice' do
    notice = build(:dmca)
    assign(:notice, notice)

    render

    expect(rendered).to include notice.title
  end

  it 'displays the date sent in the proper format' do
    notice = build(:dmca, date_sent: Time.zone.local(2013, 5, 4))
    allow(notice).to receive(:sender).and_return(build(:entity))
    assign(:notice, notice)

    render

    expect(rendered).to include 'May 04, 2013'
  end

  it 'displays the date received in the proper format' do
    notice = build(:dmca, date_received: Time.zone.local(2013, 6, 5))
    allow(notice).to receive(:recipient).and_return(build(:entity))
    assign(:notice, notice)

    render

    expect(rendered).to include 'June 05, 2013'
  end

  it 'displays a notice with tags' do
    notice = create(:dmca, :with_tags)
    assign(:notice, notice)

    render

    expect(rendered).to have_css('#tags', text: 'a_tag')
    expect(rendered).to have_facet_link(:tags, 'a_tag')
  end

  it 'displays a notice with default entities' do
    notice = create(:dmca, role_names: %w[sender recipient])
    _sender = notice.sender
    _recipient = notice.recipient

    assign(:notice, notice)

    render

    notice.entities.each do |entity|
      expect(rendered).to have_css('#entities a', text: entity.name)
      expect(rendered).to have_css('#entities span', text: entity.city)
      expect(rendered).to have_css('#entities span', text: entity.state)
      expect(rendered).to have_css('#entities span', text: entity.country_code)
      expect(rendered).to have_css('#entities span.private', text: '[Private]')
      expect(rendered).not_to have_css('#entities span',
                                       text: entity.address_line_1)
      expect(rendered).not_to have_css('#entities span',
                                       text: entity.address_line_2)
    end
  end

  it 'displays non-default entities' do
    notice = create(
      :court_order,
      role_names: %w[recipient sender principal issuing_court plaintiff
                     defendant]
    )

    assign(:notice, notice)

    render

    notice.other_entity_notice_roles.each do |role|
      expect(rendered).to have_css('.secondary.hide a', text: role.entity.name)
      expect(rendered).to have_css('.other-entities li',
                                   text: role.name.titleize)
    end
  end

  it 'displays sender_names such that they are clickable' do
    notice = create(:dmca, role_names: %w[sender principal recipient])

    assign(:notice, notice)

    render

    expect(rendered).to have_facet_link(:sender_name, notice.sender_name)
    expect(rendered).to have_facet_link(:principal_name, notice.principal_name)
    expect(rendered).to have_facet_link(:recipient_name, notice.recipient_name)
  end

  context 'showing Principal' do
    it "displays the name as 'on behalf of principal' when differing" do
      notice = create(:dmca, role_names: %w[sender principal])
      allow(notice).to receive(:on_behalf_of_principal?).and_return(true)
      assign(:notice, notice)

      render

      expect(rendered).to have_css('.sender a', text: notice.sender_name)
      expect(rendered).to have_css('.sender span', text: 'on behalf of')
      expect(rendered).to have_css('.sender a', text: notice.principal_name)
    end

    it 'does not display if not different' do
      notice = create(:dmca, role_names: %w[sender principal])
      allow(notice).to receive(:on_behalf_of_principal?).and_return(false)
      assign(:notice, notice)

      render

      expect(rendered).to have_css('.sender a', text: notice.sender_name)
      expect(rendered).not_to have_css('.sender span', text: 'on behalf of')
      expect(rendered).not_to have_css('.sender a', text: notice.principal_name)
    end
  end

  it "displays a notice's works and infringing urls" do
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
            copyrighted_urls_attributes: [
              { url: 'http://example.com/test_url_1' },
              { url: 'http://example.com/test_url_2' },
              { url: 'http://example.com/test_url_3' }
            ],
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

    have_works(notice, true, true)
  end

  it 'displays a warning about infringing urls when expected but absent' do
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
            copyrighted_urls_attributes: [
              { url: 'http://example.com/test_url_1' },
              { url: 'http://example.com/test_url_2' },
              { url: 'http://example.com/test_url_3' }
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

    have_works(notice, true, false)

    expect(rendered).to have_text 'No infringing URLs were submitted.'
  end

  it 'displays a warning about copyrighted urls when expected but absent' do
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
              { url: 'http://example.com/test_url_1' },
              { url: 'http://example.com/test_url_2' },
              { url: 'http://example.com/test_url_3' }
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

    have_works(notice, false, true)

    expect(rendered).to have_text 'No copyrighted URLs were submitted.'
  end

  it 'displays the notice source' do
    assign(:notice, build(:dmca, source: 'Arbitrary source'))

    render

    expect(rendered).to have_words('Sent via: Arbitrary source')
  end

  Notice::VALID_ACTIONS.each do |action|
    it "displays Action taken: #{action}" do
      assign(:notice, build(:dmca, action_taken: action))

      render

      expect(rendered).to have_words("Action taken: #{action}")
    end
  end

  it 'displays correctly for a notice of unknown source' do
    assign(:notice, build(:dmca, source: nil))

    render

    expect(rendered).to have_words('Sent via: Unknown')
  end

  it "displays the notice's subject" do
    assign(:notice, build(:dmca, subject: 'Some subject'))

    render

    expect(rendered).to have_words('Re: Some subject')
  end

  it 'does not link to the notices original' do
    notice = create(:dmca, :with_original, :with_pdf)
    original = notice.file_uploads.first
    assign(:notice, notice)

    render

    expect(rendered).not_to have_link(original.url)
  end

  it 'shows links to the access request form instead of supporting documents for users with no access' do
    notice = create(:dmca, :with_pdf, :with_image, :with_document)
    assign(:notice, notice)

    render

    notice.file_uploads.each do |file_upload|
      expect(rendered).to have_css(
        "ol.attachments .#{file_upload.file_type.downcase}"
      )
      expect(rendered).to have_css(
        "ol.attachments a[href=\"#{request_access_notice_path(notice)}\"]"
      )
    end
  end

  it 'shows links to supporting documents for users with access' do
    @ability.can :view_full_version, Notice
    notice = create(:dmca, :with_pdf, :with_image, :with_document)
    assign(:notice, notice)

    render

    notice.file_uploads.each do |file_upload|
      expect(rendered).to have_css(
        "ol.attachments .#{file_upload.file_type.downcase}"
      )
      expect(rendered).to have_css(
        "ol.attachments a[href=\"#{file_upload.url}\"]"
      )
    end
  end

  it 'does not show supporting documents list when empty' do
    assign(:notice, build(:dmca))

    render

    expect(rendered).not_to have_words('Supporting Documents')
    expect(rendered).not_to have_css('.attachments')
  end

  it 'shows a link to the admin page for admins' do
    notice = build_stubbed(:dmca)
    assign(:notice, notice)
    @ability.can :access, :rails_admin

    render

    expect(rendered).to contain_link(
      rails_admin.show_path(model_name: 'dmca', id: notice.id)
    )
  end

  it 'does not show a link to admin normally' do
    notice = build_stubbed(:dmca)
    assign(:notice, notice)

    render

    expect(rendered).not_to contain_link(
      rails_admin.show_path(model_name: 'dmca', id: notice.id)
    )
  end

  private

  def have_facet_link(facet, value)
    have_css(
      "a[href='#{faceted_search_path(facet => value)}']",
      text: value
    )
  end

  def have_works(notice, with_copyrighted, with_infringing)
    assign(:notice, notice)
    allow(controller).to receive(:current_user).and_return(create(:user, :admin))
    @ability.can :view_full_version, Notice

    render

    notice.works.each do |work|
      expect(rendered).to have_css("#work_#{work.id} .description",
                                   text: work.description)

      if with_copyrighted
        work.copyrighted_urls.each do |url|
          expect(rendered).to have_css("#work_#{work.id} li.copyrighted_url",
                                       text: url.url)
        end
      end

      if with_infringing
        work.infringing_urls.each do |url|
          expect(rendered).to have_css("#work_#{work.id} li.infringing_url",
                                       text: url.url)
        end
      end
    end

    allow(controller).to receive(:current_user).and_return(nil)
    @ability.cannot :view_full_version, Notice

    render

    notice.works.each do |work|
      expect(rendered).to have_css( "#work_#{work.id} .description", text: work.description )

      if with_copyrighted
        uri = URI.parse(work.copyrighted_urls.first.url)
        domain = uri.host
        expect(rendered).to have_css( "#work_#{work.id} li.copyrighted_url", text: domain + ' - 3 URLs' )
      end

      if with_infringing
        uri = URI.parse(work.infringing_urls.first.url)
        domain = uri.host
        expect(rendered).to have_css( "#work_#{work.id} li.infringing_url", text: domain + ' - 3 URLs' )
      end
    end
  end
end
