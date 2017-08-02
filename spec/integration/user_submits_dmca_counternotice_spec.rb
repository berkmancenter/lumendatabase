require 'rails_helper'

feature "DMCA counter notices" do
  scenario "A user submits a DMCA counter notice" do

    counternotice = CounterNoticeOnPage.new

    counternotice.visit_counter_notice_page

    counternotice.fill_in_user_form_with(
      'Name' => 'Your Name',
      'Phone' => '555-555-1212',
      'Address Line 1' => 'Address 1',
      'Address Line 2' => 'Address 2',
      'Address Line 3' => 'Address 3',
      'Address Line 4' => 'Address 4',
    )

    counternotice.fill_in_service_provider_form_with(
      'Name' => 'Service Provider Name',
      'Phone' => '802-555-1212',
      'Address Line 1' => 'Service Provider Address 1',
      'Address Line 2' => 'Service Provider Address 2',
      'Address Line 3' => 'Service Provider Address 3',
      'Address Line 4' => 'Service Provider Address 4',
    )

    counternotice.check('I will attach a list of works which have been removed or to which access has been disabled. I will include the location of each work before it was removed or access to it was disabled.')
    counternotice.check("Each of those works were removed in error and I believe my posting them does not infringe anyone else's rights.")
    counternotice.check('I understand that I am declaring the above under penalty of perjury, meaning that if I am not telling the truth I may be commiting a crime.')
    counternotice.check('I consent to be served by the person who gave notice to my Service Provider, or his agent.')
    counternotice.choose_radio_option('I live in the United States and I consent to the jurisdiction of the district court in whose district I reside.')

    counternotice.submit

    expect(page).to have_content('Dear Service Provider Name')
    expect(page).to have_content('Please find attached')
    expect(page).to have_content('For the purposes')
    expect(page).to have_content('Having complied')
    expect(page).to have_content('I appreciate')
    expect(page).to have_content('Service Provider Name')

  end
end
