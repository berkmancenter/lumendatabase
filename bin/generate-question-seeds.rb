#
# Produces a file suitable for db:seed which creates RelevantQuestion
# records and associates them with Topics based on what's currently
# present in the MySQL instance you connect it to.
#
###
require 'mysql2'

def blank(value)
  value.nil? || value.strip == ''
end

puts
puts "mapping = Hash.new { |hash,key| hash[key] = [] }"
puts

client = Mysql2::Client.new(
  host: '127.0.0.1',
  username: 'chill_ro',
  password: 'xxx', # CHANGEME
  port: 3307,
  database: 'chill_prod'
)

results = client.query(<<EOSQL)
  SELECT tQuestion.Question,
         tQuestion.Answer,
         tCat.CatName AS CategoryName
    FROM tQuestion
    JOIN tCat
      ON tCat.CatID = tQuestion.CatID
EOSQL

results.each do |result|
  next if blank(result['Question'])
  next if result['Question'].strip == 'QuestionID'

  if blank(result['Answer'])
    result['Answer'] = '[not yet answered]'
  end

  puts
  puts "q = RelevantQuestion.create!("
  puts " question: %{#{result['Question']}},"
  puts " answer:   %{#{result['Answer']}}"
  puts ")"
  puts
  puts "mapping[%{#{result['CategoryName']}}] << q.id"
end

puts
puts "mapping.each do |topic_name,question_ids|"
puts "  if topic = Topic.find_by_name(topic_name)"
puts "    topic.relevant_questions = RelevantQuestion.where(id: question_ids)"
puts "    topic.save!"
puts "  end"
puts "end"
puts
