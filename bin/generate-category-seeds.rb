require 'rubygems'
require 'mysql2'
require 'html2md'
require 'html2md'

@client = Mysql2::Client.new(
  host: 'localhost',
  username: 'chill_user',
  password: 'chill_pass', # CHANGEME
  port: 3306,
  database: 'chill_prod'
)

def escape(string)
  string = string.to_s
  @client.escape(
    string.encode(string.encoding, 'UTF-8', invalid: :replace)
  )
end

def get_categories
  query = 'select * from tCat order by CatID'
  @client.query(query)
end

def markdownify(string, id)
  begin
    converter = Html2Md.new(escape(string))
    converter.parse
  rescue Exception => e
    $stderr.puts "Could not markdownify #{id}"
    escape(string)
  end
end

def create_categories
  get_categories.each do |row|
    puts %Q|
  Category.create!(
    name: "#{escape(row['CatName'])}",
    description: "#{markdownify(row['Body'], row['CatID'])}",
    original_category_id: #{row['CatID']}
  )
|
  end
end

def establish_hierarchy
  get_categories.each do |row|
    if row['ParentID'] == 0
      next
    end
    puts %Q|
  cat = Category.where(original_category_id: #{row['CatID']}).first
  cat.parent = Category.where(original_category_id: #{row['ParentID']}).first
  cat.save
|
  end
end


puts "Category.transaction do"
  create_categories
  establish_hierarchy
puts "end"
