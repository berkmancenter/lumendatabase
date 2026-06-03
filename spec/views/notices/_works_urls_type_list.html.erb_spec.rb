require 'rails_helper'

describe 'notices/_works_urls_type_list.html.erb' do
  it 'renders enterprise-only domain rows without the researcher tooltip' do
    expect(Translation).not_to receive(:t)
      .with('notice_show_works_urls_full_only_researchers_tooltip')

    render partial: 'notices/works_urls_type_list',
           locals: {
             type: 'infringing',
             show_infringing: true,
             infringing_title: 'Infringing URLs',
             work: Work.new,
             url_rows: [
               {
                 text: 'other.example - 2 URLs',
                 researchers_only: false
               }
             ]
           }

    expect(rendered).to have_css('li.infringing_url', text: 'other.example - 2 URLs')
    expect(rendered).not_to have_css('i.tooltipster')
  end

  it 'keeps the researcher tooltip for public special-domain URL rows' do
    allow(Translation).to receive(:t)
      .with('notice_show_works_urls_full_only_researchers_tooltip')
      .and_return('researcher tooltip')

    infringing_url = InfringingUrl.new(url: 'other.example')
    infringing_url.only_fqdn = true
    work = Work.new(infringing_urls: [infringing_url])

    render partial: 'notices/works_urls_type_list',
           locals: {
             type: 'infringing',
             show_infringing: true,
             infringing_title: 'Infringing URLs',
             work: work
           }

    expect(rendered).to include('title="researcher tooltip"')
  end
end
