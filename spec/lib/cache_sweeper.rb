require 'spec_helper'

feature 'CacheSweeper' do
  include SearchHelpers
  scenario 'deletes the search result files', search: true, file_cache: true do
    # Turning on ActionController caching just for one test seems hard to do,
    # so we'll just create the cache files directly
    CACHE_DIR = 'tmp/test_cache'

    system("mkdir -p #{CACHE_DIR}/FFF/FFF/")
    system("touch #{CACHE_DIR}/FFF/FFF/search-result-cache-file")
    expect(search_result_cache_file_count(CACHE_DIR)).to eq(1)
    CacheSweeper.sweep_search_result_caches(CACHE_DIR)
    expect(search_result_cache_file_count(CACHE_DIR)).to eq(0)
  end

  scenario 'does not delete other files', search: true, file_cache: true do
    # Turning on ActionController caching just for one test seems hard to do,
    # so we'll just create the cache files directly
    CACHE_DIR = 'tmp/test_cache'

    system("mkdir -p #{CACHE_DIR}/FFF/FFF/")
    system("touch #{CACHE_DIR}/FFF/FFF/please-dont-delete")
    expect(cache_file_count(CACHE_DIR)).to eq(1)
    CacheSweeper.sweep_search_result_caches(CACHE_DIR)
    expect(cache_file_count(CACHE_DIR)).to eq(1)
  end
end

def search_result_cache_file_count(dir)
  Integer(`find #{dir}/ -type f -name *search-result* | wc -l`)
end

def cache_file_count(dir)
  Integer(`find #{dir}/ -type f | wc -l`)
end