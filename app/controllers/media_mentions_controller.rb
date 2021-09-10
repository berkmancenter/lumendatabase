class MediaMentionsController < ApplicationController
  def show
    return resource_not_found("Can't fing research paper with id=#{params[:id]}") unless (@media_mention = MediaMention.find_by(id: params[:id]))

    render :show
  end
end
