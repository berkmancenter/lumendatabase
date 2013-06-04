class AssociatesWorks

  def initialize(works_params, notice, submission)
    @works_params = works_params
    @notice = notice
    @submission = submission
  end

  def associate
    if works_to_associate?
      @works_params.map do |work_param|
        work = Work.find_or_initialize_by_url(
          work_param[:url],
          description: work_param[:description],
          kind: work_param[:kind]
        )
        @notice.works << work

        @submission.models << work

        work_param[:infringing_urls].each do |infringing_url_param|
          infringing_url =
            InfringingUrl.find_or_initialize_by_url(infringing_url_param)
          work.infringing_urls << infringing_url
          @submission.models << infringing_url
        end
      end
    end
  end

  private

  def works_to_associate?
    @works_params.present? &&
      @works_params.all? do |work|
        work[:url].present? && work[:infringing_urls].present?
      end
  end
end
