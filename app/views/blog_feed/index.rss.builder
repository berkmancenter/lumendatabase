#encoding: UTF-8

xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title Translation.t('blog_archive_xml_title')
    xml.author Translation.t('blog_archive_xml_author')
    xml.description Translation.t('blog_archive_xml_description')
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
