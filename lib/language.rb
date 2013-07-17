class Language
  def self.codes
    # https://www.googleapis.com/language/translate/v2/languages?key=<APIKEY>
    %w( af ar be bg ca cs cy da de el en eo es et fa fi fr ga gl hi hr
        ht hu id is it iw ja ko lt lv mk ms mt nl no pl pt ro ru sk sl
        sq sr sv sw th tl tr uk vi yi zh zh-TW )
  end
end
