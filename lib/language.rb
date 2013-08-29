Language = Struct.new(:code, :name) do
  # Only those codes supported by Google Translate API
  #
  # Codes:
  #   https://www.googleapis.com/language/translate/v2/languages?key=<APIKEY>
  #
  # Labels:
  #   http://en.wikipedia.org/w/index.php?title=List_of_ISO_639-1_codes
  #
  def self.all
    [
      Language.new('af', 'Afrikaans'),
      Language.new('ar', 'Arabic'),
      Language.new('be', 'Belarusian'),
      Language.new('bg', 'Bulgarian'),
      Language.new('ca', 'Catalan; Valencian'),
      Language.new('cs', 'Czech'),
      Language.new('cy', 'Welsh'),
      Language.new('da', 'Danish'),
      Language.new('de', 'German'),
      Language.new('el', 'Greek, Modern'),
      Language.new('en', 'English'),
      Language.new('eo', 'Esperanto'),
      Language.new('es', 'Spanish; Castilian'),
      Language.new('et', 'Estonian'),
      Language.new('fa', 'Persian'),
      Language.new('fi', 'Finnish'),
      Language.new('fr', 'French'),
      Language.new('ga', 'Irish'),
      Language.new('gl', 'Galician'),
      Language.new('hi', 'Hindi'),
      Language.new('hr', 'Croatian'),
      Language.new('ht', 'Haitian; Haitian Creole'),
      Language.new('hu', 'Hungarian'),
      Language.new('id', 'Indonesian'),
      Language.new('is', 'Icelandic'),
      Language.new('it', 'Italian'),
      Language.new('iw', 'Hebrew'),
      Language.new('ja', 'Japanese'),
      Language.new('ko', 'Korean'),
      Language.new('lt', 'Lithuanian'),
      Language.new('lv', 'Latvian'),
      Language.new('mk', 'Macedonian'),
      Language.new('ml', 'Malayalam'),
      Language.new('ms', 'Malay'),
      Language.new('mt', 'Maltese'),
      Language.new('nl', 'Dutch'),
      Language.new('no', 'Norwegian'),
      Language.new('pl', 'Polish'),
      Language.new('pt', 'Portuguese'),
      Language.new('ro', 'Romanian'),
      Language.new('ru', 'Russian'),
      Language.new('si', 'Sinhala'),
      Language.new('sk', 'Slovak'),
      Language.new('sl', 'Slovene'),
      Language.new('sq', 'Albanian'),
      Language.new('sr', 'Serbian'),
      Language.new('sv', 'Swedish'),
      Language.new('sw', 'Swahili'),
      Language.new('th', 'Thai'),
      Language.new('tl', 'Tagalog'),
      Language.new('tr', 'Turkish'),
      Language.new('uk', 'Ukrainian'),
      Language.new('vi', 'Vietnamese'),
      Language.new('yi', 'Yiddish'),
      Language.new('yo', 'Yoruba'),
      Language.new('zh', 'Chinese'),
    ]
  end

  def self.codes
    all.map(&:code)
  end

  def label
    "#{code} - #{name}"
  end
end
