class TrademarkSerializer < NoticeSerializer
  attributes :marks, :mark_registration_number

  def marks
    object.works.map do |work|
      {
        description: work.description,
        infringing_urls: work.infringing_urls.map(&:url)
      }
    end
  end

  private

  def attributes
    hsh = super
    hsh.delete(:works)

    hsh
  end
end
