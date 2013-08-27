RiskTrigger.create!(
  field: :body,
  condition_field: :country_code,
  condition_value: 'United States',
  negated: true
)
