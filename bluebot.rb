require "cinch"
require "cinch/plugins/identify"
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

bot = Cinch::Bot.new do
  configure do |c|
    c.server   =  ENV["BLUEBOT_SERVER"]   || "irc.freenode.org"
    c.channels = [ENV["BLUEBOT_CHANNEL"]  || "#cinch-bots"]
    c.nick     =  ENV["BLUEBOT_NICK"]     || "bluebot"
    c.realname =  ENV["BLUEBOT_NICK"]     || "bluebot"
    c.user     =  ENV["BLUEBOT_NICK"]     || "bluebot"

    c.plugins.plugins = [Cinch::Plugins::Identify,
                         Cinch::Plugins::UrlScraper]

    c.plugins.options[Cinch::Plugins::Identify] = {
      username: ENV["BLUEBOT_NICK"]     || "",
      password: ENV["BLUEBOT_PASSWORD"] || "",
      type:     :nickserv,
    }
  end

  on :message, "!hello" do |m|
    m.reply "Hello, #{m.user.nick}!"
  end

  # Karma

  on :message, /\A(\S+)\+\+/ do |m, what|
    add_karma(db, what, 1)
    m.reply "Upvoted #{what}."
  end

  on :message, /\A(\S+)--/ do |m, what|
    add_karma(db, what, -1)
    m.reply "Downvoted #{what}."
  end

  on :message, /\A!karma (\S+)/ do |m, what|
    item  = db["karma"].find({"item" => what}).next
    karma = item.nil? ? 0 : item["karma"]
    m.reply "Karma for #{what}: #{karma}."
  end  

  # Quotes
  
  on :message, /\A!addquote (.+)/ do |m, quote|
    db["quotes"].insert({"quote" => quote})
    num = db["quotes"].count()
    m.reply "Added quote \##{num}: \"#{quote}\"."
  end

  on :message, /\A!quote (\d*)/ do |m, num|
    begin
      quote = db["quotes"].find().to_a[num.to_i - 1]["quote"]
      m.reply "Quote \##{num}: \"#{quote}\"."
    rescue
      m.reply "Quote not found."
    end
  end

  on :message, "!lastquote" do |m|
    quotes = db["quotes"].find().to_a
    last   = quotes.last["quote"]
    m.reply "Quote \##{quotes.length}: \"#{last}\"."
  end

  on :message, /\A!searchquote (.+)/ do |m, keywords|
    indexes = []
    quotes  = db["quotes"].find().to_a
    quotes.each_index do |idx|
      indexes << (idx + 1) unless quotes[idx]["quote"].downcase.index(keywords.downcase).nil?
    end
    m.reply "Quotes matching \"#{keywords}\": #{indexes}."
  end
end

def add_karma(db, what, how_much)
  item  = db["karma"].find({"item" => what}).next
  if item.nil?
    db["karma"].insert({"item" => what, "karma" => how_much})
  else
    karma = item["karma"].to_i + how_much
    db["karma"].update({"item" => what}, {"$set" => {"karma" => karma}})
  end    
end

bot.start