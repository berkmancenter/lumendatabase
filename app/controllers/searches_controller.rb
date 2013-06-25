class SearchesController < ApplicationController

  def show
    term = params[:term]
    p = params[:page]
    category_filter = params[:categories]
    submitter_name_filter = params[:submitter_name]
    recipient_name_filter = params[:recipient_name]
    now = Time.now.beginning_of_day

    date_filters = date_received_filters

    @results = Notice.search(page: p) do
      query { match(:_all, term) }

      if category_filter.present?
        filter :terms, category_facet: [ category_filter ]
      end

      if submitter_name_filter.present?
        filter :terms, submitter_name_facet: [ submitter_name_filter ]
      end

      if recipient_name_filter.present?
        filter :terms, recipient_name_facet: [ recipient_name_filter ]
      end

      if date_filters
        filter :range, date_received: {
          from: date_filters.from, to: date_filters.to
        }
      end

      facet :submitter_name do
        terms :submitter_name_facet
      end

      facet :recipient_name do
        terms :recipient_name_facet
      end

      facet :categories do
        terms :category_facet
      end

      facet :date_received do
        range :date_received, [
          { from: now - 1.day, to: now },
          { from: now - 1.month, to: now },
          { from: now - 6.months, to: now },
          { from: now - 12.months, to: now }
        ]
      end

      highlight(*Notice::HIGHLIGHTS)
    end

    respond_to do |format|
      format.html
      format.json do
        render(
          json: @results,
          each_serializer: NoticeSearchResultSerializer,
          serializer: ActiveModel::ArraySerializer,
          root: 'notices',
          meta: meta_hash_for(@results)
        )
      end
    end
  end

  private

  def date_received_filters
    if params[:date_received].present?
      @date_received_filters ||= DateReceivedFilters.new(params[:date_received])
    end
  end

  def meta_hash_for(results)
    %i(
      current_page next_page offset per_page
      previous_page total_entries total_pages
    ).each_with_object(query_meta(results)) do |attribute, memo|
      memo[attribute] = results.send(attribute)
    end
  end

  def query_meta(results)
    {
      query: {
        term: params[:term]
      }.merge(facet_query_meta(results)),
      facets: results.facets
    }
  end

  def facet_query_meta(results)
    results.facets.keys.each_with_object({}) do |facet, memo|
      if params[facet.to_sym].present?
        memo[facet.to_sym] = params[facet.to_sym]
      end
    end
  end

  class DateReceivedFilters
    def initialize(date_received)
      @date_received = date_received
    end
    def to
      Time.at(@date_received.split(Notice::RANGE_SEPARATOR)[1].to_i / 1000)
    end
    def from
      Time.at(@date_received.split(Notice::RANGE_SEPARATOR)[0].to_i / 1000)
    end
  end

end
