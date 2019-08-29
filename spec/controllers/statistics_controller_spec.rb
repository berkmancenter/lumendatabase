require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do
	context 'as HTML' do
		it 'renders notices successfully' do
			get :notices
			expect(response).to be_successful
		end

		it 'renders urls page successfully' do
			get :infringing_urls
			expect(response).to be_successful
		end

		it 'renders entities page successfully' do
			get :entities
			expect(response).to be_successful 
		end
	end

	context 'as JSON' do
		it 'renders json for datewise_notices' do
			get :datewise_notices
			expect(response).to be_successful
		end

		it 'renders json for datewise_urls' do
			get :datewise_urls
			expect(response).to be_successful
		end
	end

end
