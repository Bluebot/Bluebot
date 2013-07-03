require "cinch"
require "cinch/plugins/urlscraper"
require "mongo"

include Mongo

def get_db
  if ENV["MONGOHQ_URL"].nil?
    MongoClient.new("localhost", 27017).db("bluebot")
  else
    mongo_uri = ENV["MONGOHQ_URL"]
    db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
    client = MongoClient.from_uri(mongo_uri)
    client.db(db_name)
  end
end

db = get_db

puts "Colecciones en la base:"
db.collection_names.each { |name| puts name }

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#cinch-bots"]
    c.plugins.plugins = [Cinch::Plugins::UrlScraper]
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}"
  end  
end

bot.start