require 'spec_helper'

describe 'notices/show.html.erb' do
  it "displays a metadata from a notice" do
    notice = build(:dmca)
    assign(:notice, notice)

    render

    expect(rendered).to include notice.title
  end

  it "displays the date sent in the proper format" do
    notice = build(:dmca, date_sent: Time.local(2013, 5, 4))
    notice.stub(:sender).and_return(build(:entity))
    assign(:notice, notice)

    render

    expect(rendered).to include "May 04, 2013"
  end

  it "displays the date received in the proper format" do
    notice = build(:dmca, date_received: Time.local(2013, 6, 5))
    notice.stub(:recipient).and_return(build(:entity))
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

  it "displays a notice with entities" do
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

  it "displays sender_names such that they are clickable" do
    notice = create(:dmca, role_names: ['sender', 'recipient'])

    assign(:notice, notice)

    render

    within('#entities') do
      expect(page).to have_facet_link(:sender_name, notice.sender_name)
      expect(page).to have_facet_link(:recipient_name, notice.recipient_name)
    end
  end

  it "displays a notice with all relevant questions" do
    category_question = create(:relevant_question, question: "Q 1", answer: "A 1")
    notice_question = create(:relevant_question, question: "Q 2", answer: "A 2")
    assign(:notice, create(:dmca,
      categories: [create(:category, relevant_questions: [category_question])],
      relevant_questions: [notice_question]
    ))

    render

    [category_question, notice_question].each do |question|
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
    notice.stub(:limited_related_blog_entries).and_return(blog_entries)
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
    notice = create(:dmca, :with_original)
    original = notice.file_uploads.first
    assign(:notice, notice)

    render

    within('ol.attachments') do
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

  private

  def have_facet_link(facet, value)
    have_css(
      "a[href='#{faceted_search_path(facet => value)}']",
      text: value
    )
  end

end
