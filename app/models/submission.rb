class Submission
  def self.create!(params)
    submission = new(params)
    submission.save!
  end

  def initialize(params)
    @params = params
  end

  def save!
    Notice.create!(params.slice(:title))
    if params[:file].present?
      FileUpload.create!(params.slice(:file))
    end
  end

  private

  attr_reader :params

end
