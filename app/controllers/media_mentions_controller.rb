class MediaMentionsController < ApplicationController
  def show
    return resource_not_found("Can't find a research paper with id=#{params[:id]}") unless (@media_mention = MediaMention.find_by(id: params[:id]))

    LumenLogger.log_metrics('VIEWED_MEDIA_MENTION', media_mention: @media_mention.title, media_mention_id: @media_mention.id)

    render :show
  end
end
