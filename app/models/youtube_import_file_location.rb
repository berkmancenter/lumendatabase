# frozen_string_literal: true

class YoutubeImportFileLocation < ApplicationRecord
  belongs_to :file_upload

  validates_presence_of :path
end
