# encoding: UTF-8

xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'Lumen Database Blog'
    xml.author 'Lumen Database'
    xml.description 'Lumen Database is an independent 3rd party research project studying cease and desist letters concerning online content.'
    xml.link 'https://www.lumendatabase.org/'
    xml.language 'en'

    for article in @blog_articles
      xml.item do
        if article.title
          xml.title article.title
        else
          xml.title ''
        end
        xml.author article.author
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.link 'https://www.lumendatabase.org/blog_entries/' + article.id.to_s
        xml.guid article.id

        text = article.content_html
        xml.description '<p>' + text + '</p>'
      end
    end
  end
end
