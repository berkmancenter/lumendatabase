module Redaction
  class RefillQueue
    SelectInput = Struct.new(:label_text, :collection) do
      def key
        label_text.downcase.gsub(/\s+/, '_').to_sym
      end
    end

    def initialize(params = {})
      @params = params
    end

    def each_input
      yield SelectInput.new('In topics', Topic.all)
    end

    def fill(queue)
      return if queue.full?

      scopes = params.fetch(root_key, {})
      relation = base_relation

      scopes.each do |scope, argument|
        relation = relation.send(scope, argument) if argument.present?
      end

      relation.limit(queue.available_space).update_all(reviewer_id: queue.user)
    end

    def root_key
      :notice_scopes
    end

    private

    attr_reader :params

    def base_relation
      Notice.available_for_review
    end
  end
end
