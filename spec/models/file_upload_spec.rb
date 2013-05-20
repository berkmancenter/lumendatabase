require 'spec_helper'

describe FileUpload do
  it { should have_attached_file(:file) }
end
