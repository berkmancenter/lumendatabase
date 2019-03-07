require 'rails_helper'

describe Notice, type: :model do
  it 'does not have an index name suffix when the ENV variable is unset' do
    cached = ENV['ES_INDEX_SUFFIX']

    ENV.delete 'ES_INDEX_SUFFIX'
    Object.send(:remove_const, 'Notice')
    load 'app/models/notice.rb'
    expect(Notice.index_name).to eq 'chill_application_test_notice'

    ENV['ES_INDEX_SUFFIX'] = cached if cached
  end

  it 'uses the index name suffix when the ENV variable is set' do
    cached = ENV['ES_INDEX_SUFFIX']

    ENV['ES_INDEX_SUFFIX'] = 'testme'
    Object.send(:remove_const, 'Notice')
    load 'app/models/notice.rb'
    expect(Notice.index_name).to eq 'chill_application_test_notice_testme'

    ENV['ES_INDEX_SUFFIX'] = cached if cached
  end
end
