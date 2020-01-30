#encoding: UTF-8

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Lumen Database Blog"
    xml.author "Lumen Database"
    xml.description "Lumen Database is an independent 3rd party research project studying cease and desist letters concerning online content."
    xml.link "https://www.lumendatabase.org/"
    xml.language "en"

    @blog_articles.each do |article|
      xml.item do
        xml.title article.title
        xml.author article.author
        xml.pubDate article.pubDate
        xml.link article.link
        xml.guid article.guid
        xml.description article.description
        xml.text article.content
      end
    end
  end
end
