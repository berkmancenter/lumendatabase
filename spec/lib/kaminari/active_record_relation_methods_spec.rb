require 'spec_helper'

describe 'Customized kaminari counting' do
  it 'counts for configured tables' do
    table_name = 'a_table'
    dummy = Dummy.new(table_name)
    execute_double = stub_execute(dummy)

    expect(execute_double).to receive(:execute)

    with_configured_pagination_overrides([ table_name ]) do
      dummy.total_count
    end
  end

  it 'does not count for unconfigured tables' do
    table_name = 'a_table'
    different_table_name = 'some_other_table_name'

    dummy = Dummy.new(table_name)
    execute_double = stub_execute(dummy)

    expect(execute_double).not_to receive(:execute)

    with_configured_pagination_overrides([ different_table_name ]) do
      begin
        dummy.total_count
      rescue
      end
    end
  end

  def stub_execute(dummy)
    double('Execute double', execute: [{ 'reltuples' => 100 }]).tap do |execute_double|
      allow(dummy).to receive(:connection).and_return(execute_double)
    end
  end

  def with_configured_pagination_overrides(tables)
    original_tables_with_naive_counts = Chill::Application.config.tables_using_naive_counts
    begin
      Chill::Application.config.tables_using_naive_counts = tables
      yield
    ensure
      Chill::Application.config.tables_using_naive_counts = original_tables_with_naive_counts
    end
  end

  class Dummy
    include Kaminari::ActiveRecordRelationMethods
    attr_reader :table_name
    def initialize(table_name)
      @table_name = table_name
    end
  end
end

