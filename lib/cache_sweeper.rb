class CacheSweeper
  def self.sweep_search_result_caches(dir='tmp/cache')
    # We were previously using the expire_fragment method but it was randomly
    # generating "No such file or directory @ dir_initialize" errors
    system("find #{dir} -name '*search-result*' -delete")
  end
end