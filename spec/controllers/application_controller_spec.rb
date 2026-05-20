require 'rails_helper'

describe ApplicationController do
  describe '#after_sign_in_path_for' do
    it 'sends enterprise users to their sorted client notices' do
      resource = Object.new

      def resource.enterprise?
        true
      end

      expect(controller.after_sign_in_path_for(resource)).to eq(
        client_notices_search_index_path(sort_by: 'created_at desc')
      )
    end
  end
end
