class HashEmailsInTokenUrls < ActiveRecord::Migration[6.1]
  def change
    TokenUrl.where(valid_forever: true).each do |token_url|
      token_url.email = token_url.user.email
      token_url.save!
    end
  end
end
