require 'rails_helper'

describe 'notices/show.html.erb' do
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    allow(view.controller).to receive(:current_ability) { @ability }
  end

  it "displays a metadata from a notice" do
    notice = build(:dmca)
    assign(:notice, notice)

    render

    expect(rendered).to include notice.title
  end

  it "displays the date sent in the proper format" do
    notice = build(:dmca, date_sent: Time.local(2013, 5, 4))
    allow(notice).to receive(:sender).and_return(build(:entity))
    assign(:notice, notice)

    render

    expect(rendered).to include "May 04, 2013"
  end

  it "displays the date received in the proper format" do
    notice = build(:dmca, date_received: Time.local(2013, 6, 5))
    allow(notice).to receive(:recipient).and_return(build(:entity))
    assign(:notice, notice)

    render

    expect(rendered).to include "June 05, 2013"
  end

  it "displays a notice with tags" do
    notice = create(:dmca, :with_tags)
    assign(:notice, notice)

    render

    within('#tags') do
      expect(page).to have_content("a_tag")
      expect(page).to have_facet_link(:tags, 'a_tag')
    end
  end

  it "displays a notice with default entities" do
    notice = create(:dmca, role_names: ['sender', 'recipient'])

    assign(:notice, notice)

    render

    within('#entities') do
      notice.entities.each do |entity|
        expect(page).to have_content(entity.name)
        expect(page).to have_content(entity.city)
        expect(page).to have_content(entity.state)
        expect(page).to have_content(entity.country_code)
        expect(page).to have_content("[Private]")
        expect(page).not_to have_content(entity.address_line_1)
        expect(page).not_to have_content(entity.address_line_2)
      end
    end
  end

  it "displays non-default entities" do
    notice = create(
      :court_order,
      role_names: %w|recipient sender principal issuing_court plaintiff defendant|
    )

    assign(:notice, notice)

    render

    within('#entities') do
      within('.other-entities') do
        notice.other_entity_notice_roles.each do |role|
          expect(page).to have_content(role.name.titleize)
        end
      end

      within('.entities-wrapper') do
        notice.other_entity_notice_roles.each do |role|
          expect(page).to have_content(role.entity.name)
        end
      end
    end
  end

  it "displays sender_names such that they are clickable" do
    notice = create(:dmca, role_names: %w( sender principal recipient ))

    assign(:notice, notice)

    render

    within('#entities') do
      expect(page).to have_facet_link(:sender_name, notice.sender_name)
      expect(page).to have_facet_link(:principal_name, notice.principal_name)
      expect(page).to have_facet_link(:recipient_name, notice.recipient_name)
    end
  end

  context "showing Principal" do
    it "displays the name as 'on behalf of principal' when differing" do
      notice = create(:dmca, role_names: %w( sender principal ))
      allow(notice).to receive(:on_behalf_of_principal?).and_return(true)
      assign(:notice, notice)

      render

      within('#entities .sender') do
        expect(page).to have_content(notice.sender_name)
        expect(page).to have_content("on behalf of #{notice.principal_name}")
      end
    end

    it "does not display if not different" do
      notice = create(:dmca, role_names: %w( sender principal ))
      allow(notice).to receive(:on_behalf_of_principal?).and_return(false)
      assign(:notice, notice)

      render

      within('#entities .sender') do
        expect(page).to have_content(notice.sender_name)
        expect(page).not_to have_content("on behalf of #{notice.principal_name}")
      end
    end
  end

  it "displays a notice with all relevant questions" do
    topic_question = create(:relevant_question, question: "Q 1", answer: "A 1")
    notice_question = create(:relevant_question, question: "Q 2", answer: "A 2")
    assign(:notice, create(:dmca,
      topics: [create(:topic, relevant_questions: [topic_question])],
      relevant_questions: [notice_question]
    ))

    render

    [topic_question, notice_question].each do |question|
      within("#relevant_question_#{question.id}") do
        expect(page).to have_content(question.question)
        expect(page).to have_content(question.answer)
      end
    end
  end

  it "displays a notice's works and infringing urls" do
    notice = create(:dmca, :with_infringing_urls, :with_copyrighted_urls)
    assign(:notice, notice)

    render

    notice.works.each do |work|
      within("#work_#{work.id}") do
        expect(page).to have_content(work.description)

        expect(notice.copyrighted_urls).to exist
        expect(notice.copyrighted_urls).to exist

        work.copyrighted_urls.each do |copyrighted_url|
          expect(page).to have_content(copyrighted_url.url)
        end

        work.infringing_urls.each do |url|
          within("#infringing_url_#{url.id}") do
            expect(page).to have_content(url.url)
          end
        end
      end
    end
  end

  it "displays the notice source" do
    assign(:notice, build(:dmca, source: "Arbitrary source"))

    render

    expect(page).to have_content("Sent via: Arbitrary source")
  end

  Notice::VALID_ACTIONS.each do |action|
    it "displays Action taken: #{action}" do
      assign(:notice, build(:dmca, action_taken: action))

      render

      expect(page).to have_content("Action taken: #{action}")
    end
  end

  it "displays correctly for a notice of unknown source" do
    assign(:notice, build(:dmca, source: nil))

    render

    expect(page).to have_content("Sent via: Unknown")
  end

  it "displays the notice's subject" do
    assign(:notice, build(:dmca, subject: "Some subject"))

    render

    expect(page).to have_content("Re: Some subject")
  end

  it "displays limited related blog entries" do
    blog_entries = build_stubbed_list(:blog_entry, 3)
    notice = build(:dmca)
    allow(notice).to receive(:related_blog_entries).and_return(blog_entries)
    assign(:notice, notice)

    render

    blog_entries.each do |blog_entry|
      within("#blog_entry_#{blog_entry.id}") do
        expect(page).to(
          contain_link(blog_entry_path(blog_entry), blog_entry.title)
        )
      end
    end
  end

  it "does not link to the notices original" do
    notice = create(:dmca, :with_original, :with_pdf)
    original = notice.file_uploads.first
    assign(:notice, notice)

    render

    within('.main') do
      expect(page).not_to contain_link(original.url)
    end
  end

  it "shows links to supporting documents" do
    notice = create(:dmca, :with_pdf, :with_image, :with_document)
    assign(:notice, notice)

    render

    notice.file_uploads.each do |file_upload|
      within("ol.attachments .#{file_upload.file_type.downcase}") do
        expect(page).to contain_link(file_upload.url)
      end
    end
  end

  it "does not show supporting documents list when empty" do
    assign(:notice, build(:dmca))

    render

    expect(page).not_to have_content('Supporting Documents')
    expect(page).not_to have_css('.attachments')
  end

  it "shows a link to the admin page for admins" do
    notice = build_stubbed(:dmca)
    assign(:notice, notice)
    @ability.can :access, :rails_admin

    render

    expect(page).to contain_link(
      rails_admin.show_path(model_name: 'dmca', id: notice.id)
    )
  end

  it "does not show a link to admin normally" do
    notice = build_stubbed(:dmca)
    assign(:notice, notice)

    render

    expect(page).not_to contain_link(
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

end
