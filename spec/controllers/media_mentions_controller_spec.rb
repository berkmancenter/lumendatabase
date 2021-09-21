require 'rails_helper'

describe MediaMentionsController do
  context '#show' do
    it 'finds the notice when it exists and renders successfully' do
      media_mention = MediaMention.new(title: 'Go Lumen!', scale_of_mention: 'Small')
      expect(MediaMention).to receive(:find_by).with(id: '1').and_return(media_mention)

      get :show, params: { id: 1 }

      expect(response).to be_successful
      expect(assigns(:media_mention)).to eq media_mention
    end
  end
end
