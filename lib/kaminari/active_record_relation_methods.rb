module Kaminari
  module ActiveRecordRelationMethods
    def total_count
      @total_count ||= begin
       if Chill::Application.config.tables_using_naive_counts.include?(table_name)
         get_naive_total_count
       else
         get_actual_count
       end
      end
    end

    def get_actual_count
      # This is extracted fairly directly from the original
      # Kaminari::ActiveRecordRelationMethods class

      c = except(:offset, :limit, :order)

      # Remove includes only if they are irrelevant
      c = c.except(:includes) unless references_eager_loaded_tables?

      # a workaround to count the actual model instances on distinct query because count + distinct returns wrong value in some cases. see https://github.com/amatsuda/kaminari/pull/160
      uses_distinct_sql_statement = c.to_sql =~ /DISTINCT/i
      if uses_distinct_sql_statement
        c.length
      else
        # .group returns an OrderdHash that responds to #count
        c = c.count
        c.respond_to?(:count) ? c.count : c
      end
    end

    def get_naive_total_count
      result = connection.execute(
        "SELECT (reltuples)::integer FROM pg_class r WHERE relkind = 'r' AND relname ='#{table_name}'"
      )
      result.first["reltuples"].to_i
    end
  end
end
