Lumen.const_set :SETTINGS, LumenSetting.all rescue nil
Lumen.const_set :UNKNOWN_WORK, Work.unknown rescue nil
Lumen.const_set :TRUNCATION_TOKEN_URLS_ACTIVE_PERIOD, 24.hours
Lumen.const_set :REDACTION_MASK, '[REDACTED]'.freeze
Lumen.const_set :OTHER_TOPIC, 'Uncategorized'.freeze
Lumen.const_set :TYPES_TO_TOPICS, {
  'DMCA'                  => 'Copyright',
  'Counterfeit'           => 'Counterfeit',
  'Counternotice'         => 'Copyright',
  'CourtOrder'            => 'Court Orders',
  'DataProtection'        => 'EU - Right to Be Forgotten',
  'Defamation'            => 'Defamation',
  'GovernmentRequest'     => 'Government Requests',
  'LawEnforcementRequest' => 'Law Enforcement Requests',
  'PrivateInformation'    => 'Right of Publicity',
  'Trademark'             => 'Trademark',
  'Other'                 => Lumen::OTHER_TOPIC,
  'Placeholder'           => Lumen::OTHER_TOPIC
}.freeze
Lumen.const_set :TYPES, Lumen::TYPES_TO_TOPICS.keys
Lumen.const_set :TOPICS, Lumen::TYPES_TO_TOPICS.values
