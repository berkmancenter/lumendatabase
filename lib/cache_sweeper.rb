class CacheSweeper
  def self.sweep_search_result_caches
    # We were previously using the expire_fragment method but it was randomly
    # generating "No such file or directory @ dir_initialize" errors
    system("find tmp/cache -name '*search-result*' -delete")
  end
end