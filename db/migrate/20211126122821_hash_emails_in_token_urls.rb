class HashEmailsInTokenUrls < ActiveRecord::Migration[6.1]
  def change
    TokenUrl.all.each do |token_url|
      token_url.email = Hasher.hash512(token_url.email)
      token_url.ip = Hasher.hash512(token_url.ip)
      token_url.save!
    end
  end
end
