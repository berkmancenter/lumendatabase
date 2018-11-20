class DMCACounterNotice
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(attributes = {})
    attributes.respond_to?(:keys) && attributes.keys.each do |key|
      if self.respond_to?("#{key}=".to_sym)
        self.send("#{key}=".to_sym, attributes[key])
      end
    end
  end

  JURISDICTIONS = [
    'I live in the United States and I consent to the jurisdiction of the district court in whose district I reside.',
    'I live outside the United States and I consent to the jurisdiction of any judicial district in which my service provider may be found.'
  ]

  validates_presence_of :attach_list_of_works, :list_removed_in_error,
    :perjury_risk_acknowledged, :consent_to_be_served, :jurisdiction

  attr_accessor *%i(
  attach_list_of_works
  list_removed_in_error
  perjury_risk_acknowledged
  jurisdiction
  consent_to_be_served

  your_name
  your_phone
  your_address_line_1
  your_address_line_2
  your_address_line_3
  your_address_line_4

  service_provider_name
  service_provider_phone
  service_provider_address_line_1
  service_provider_address_line_2
  service_provider_address_line_3
  service_provider_address_line_4
  )

  def in_us?
    jurisdiction && jurisdiction.match(/I live in the United States/)
  end

  def persisted?
    false
  end
end
