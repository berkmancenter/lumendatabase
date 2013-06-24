RiskTrigger.create!(
  field: :legal_other,
  condition_field: :country_code,
  condition_value: 'United States',
  negated: true
)
