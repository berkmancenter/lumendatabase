module SearchHelpers
  SEARCH_INDEXED_MODELS = [Notice, Entity].freeze
  SEARCH_INDEX_WAIT_TIMEOUT = ENV.fetch('SEARCH_INDEX_WAIT_TIMEOUT', 10).to_f
  SEARCH_INDEX_WAIT_INTERVAL = ENV.fetch('SEARCH_INDEX_WAIT_INTERVAL', 0.1).to_f

  def index_changed_instances(*models, timeout: SEARCH_INDEX_WAIT_TIMEOUT)
    make_search_records_visible_to_logstash(models)
    expected_states = expected_search_index_states(models)
    return if expected_states.empty?

    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    last_states = {}

    loop do
      last_states = current_search_index_states(expected_states)
      return if expected_states.all? do |model, expected_state|
        search_index_state_matches?(expected_state, last_states.fetch(model))
      end

      if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
        raise search_index_timeout_message(timeout, expected_states, last_states)
      end

      sleep SEARCH_INDEX_WAIT_INTERVAL
    end
  end

  def submit_search(term)
    visit '/'

    fill_in 'search', with: term
    click_on 'submit'
  end

  def search_for(searches)
    query = searches.map { |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')

    visit "/notices/search?#{query}"
  end

  def within_search_results_for(term)
    submit_search(term)
    within('.search-results') do
      yield if block_given?
    end
  end

  def open_dropdown_for_facet(facet)
    toggle_selector = ".dropdown-toggle.#{facet}"

    # Clicking the toggle fires a one-shot handler (faceted_search_form.js) that
    # AJAX-loads the facet buckets and marks the toggle data-loaded; the bucket
    # links do not exist until then. The click occasionally fails to register
    # (it lands during a re-render), leaving the dropdown with only its
    # server-rendered "All" entry and no data-loaded flag — so the value link is
    # never found. A no-op click changes nothing, so retry until the load fires.
    attempts = 0
    loop do
      find(toggle_selector).click
      break if has_css?("#{toggle_selector}[data-loaded]", wait: 2)
      raise "facet dropdown '#{facet}' failed to open after #{attempts} retries" if
        (attempts += 1) >= 5
    end
  end

  def open_and_select_facet(facet, facet_value)
    open_dropdown_for_facet(facet)

    within("ol.#{facet}") do
      # The gsub converts newlines to spaces as they can break the regex.
      # normalize_ws ensures that it doesn't matter if we did this.
      find(
        'a',
        text: /#{facet_value.gsub(/[\r\n]+/, ' ')}/,
        normalize_ws: true,
        visible: false
      ).click
    end
  end

  def submit_faceted_search(term, facet, facet_value)
    visit '/'

    fill_in 'search', with: term
    click_on 'submit'

    open_and_select_facet(facet, facet_value)
  end

  def within_faceted_search_results_for(term, facet, facet_value)
    submit_faceted_search(term, facet, facet_value)

    within('.search-results') do
      yield if block_given?
    end
  end

  def have_n_results(count)
    have_css('.result', count: count)
  end

  def have_active_facet_dropdown(facet_type)
    have_css(".dropdown.#{facet_type}.active")
  end

  def have_active_facet(facet_type, facet)
    find(".dropdown-toggle.#{facet_type}").click
    have_css('.dropdown-menu li.active a', text: /^#{facet}/)
  end

  def with_metadata(notice, options = {})
    metadata = {
      '_type' => "notice",
      '_score' => 0.5,
      '_index' => "development__notices",
      '_version' => nil,
      '_explanation' => nil,
      'sort' => nil,
      'class_name' => notice.class.to_s,
      'highlight' => nil
    }.merge(options)

    notice.as_indexed_json({}).merge(metadata)
  end

private

  def make_search_records_visible_to_logstash(models)
    timestamp = next_search_index_timestamp
    models = models.flatten.presence || SEARCH_INDEXED_MODELS

    models.each do |model|
      ids = model.pluck(:id)
      next if ids.empty?

      model.where(id: ids).update_all(updated_at: timestamp)
    end
  end

  def expected_search_index_states(models)
    models = models.flatten.presence || SEARCH_INDEXED_MODELS

    models.each_with_object({}) do |model, states|
      ids = model.pluck(:id)
      next if ids.empty?

      states[model] = {
        ids: ids,
        count: ids.size,
        max_updated_at: timestamp_in_milliseconds(model.maximum(:updated_at))
      }
    end
  end

  def current_search_index_states(expected_states)
    expected_states.each_with_object({}) do |(model, expected_state), states|
      client = model.__elasticsearch__.client
      index = model.__elasticsearch__.index_name

      client.indices.refresh(index: index)
      response = client.search(
        index: index,
        body: {
          size: 0,
          track_total_hits: true,
          query: {
            ids: {
              values: expected_state[:ids]
            }
          },
          aggs: {
            max_updated_at: { max: { field: 'updated_at' } }
          }
        }
      )

      states[model] = {
        ids: expected_state[:ids],
        count: search_response_count(response),
        max_updated_at: response.dig(
          'aggregations', 'max_updated_at', 'value'
        )&.floor
      }
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      states[model] = {
        ids: expected_state[:ids],
        count: 0,
        max_updated_at: nil
      }
    end
  end

  def search_index_state_matches?(expected_state, actual_state)
    actual_state[:count] >= expected_state[:count] &&
      (actual_state[:max_updated_at] || 0) >= expected_state[:max_updated_at]
  end

  def timestamp_in_milliseconds(timestamp)
    (timestamp.to_f * 1000).floor
  end

  def next_search_index_timestamp
    SearchHelpers.next_search_index_timestamp
  end

  class << self
    def next_search_index_timestamp
      search_index_timestamp_mutex.synchronize do
        timestamp = Time.current + 100.years
        timestamp = @search_index_timestamp + 1.second if
          @search_index_timestamp && timestamp <= @search_index_timestamp

        @search_index_timestamp = timestamp
      end
    end

    def search_index_timestamp_mutex
      @search_index_timestamp_mutex ||= Mutex.new
    end
  end

  def search_response_count(response)
    total = response.dig('hits', 'total')
    return total['value'] if total.is_a?(Hash)

    total
  end

  def search_index_timeout_message(timeout, expected_states, last_states)
    expected = format_search_index_states(expected_states)
    actual = format_search_index_states(last_states)

    "Timed out after #{timeout}s waiting for Logstash to index test records " \
      "(expected #{expected}; indexed #{actual}). " \
      "Check `docker compose logs logstash_test` for indexing errors."
  end

  def format_search_index_states(states)
    states.map do |model, state|
      "#{model.name}=#{state[:count]}/#{state[:ids]&.size || '?'}@" \
        "#{state[:max_updated_at] || 'never'}"
    end.join(', ')
  end
end
