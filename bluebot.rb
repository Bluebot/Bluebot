# -*- coding: utf-8 -*-
require "mongo"
require "cinch"
require "cinch/plugins/identify"
require "cinch/plugins/urlscraper"
require_relative "plugins/cleverbot"

include Mongo

def get_db
  if ENV["MONGOHQ_URL"].nil?
    MongoClient.new("localhost", 27017).db("bluebot")
  else
    mongo_uri = ENV["MONGOHQ_URL"]
    db_name = mongo_uri[%r{/([^/\?]+)(\?|$)}, 1]
    MongoClient.from_uri(mongo_uri).db(db_name)
  end
end

db = get_db

bot = Cinch::Bot.new do
  configure do |c|
    c.server   =  ENV["BLUEBOT_SERVER"]  || "irc.freenode.org"
    c.channels = [ENV["BLUEBOT_CHANNEL"] || "#cinch-bots"]
    c.nick     =  ENV["BLUEBOT_NICK"]    || "bluebot"
    c.realname =  ENV["BLUEBOT_NICK"]    || "bluebot"
    c.user     =  ENV["BLUEBOT_NICK"]    || "bluebot"

    c.plugins.plugins = [Cinch::Plugins::Identify,
                         Cinch::Plugins::UrlScraper,
                         Cinch::Plugins::CleverBot]

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
  end

  on :message, /\A(\S+)--/ do |m, what|
    add_karma(db, what, -1)
  end

  on :message, /\A!karma\Z/ do |m, num|
    m.reply get_karma(db, m.user.nick)
  end

  on :message, /\A!karma (\S+)/ do |m, what|
    m.reply get_karma(db, what)
  end  

  # Quotes
  
  on :message, /\A!addquote (.+)/ do |m, quote|
    db["quotes"].insert({"quote" => quote})
    num = db["quotes"].count()
    m.reply "Added quote \##{num}: \"#{quote}\"."
  end

  on :message, /\A!quote\Z/ do |m, num|
    m.reply get_quote(db, 1 + rand(db["quotes"].count()))
  end

  on :message, /\A!quote (\d+)/ do |m, num|
    m.reply get_quote(db, num)
  end

  on :message, "!lastquote" do |m|
    m.reply get_quote(db, db["quotes"].count())
  end

  on :message, /\A!searchquote (.+)/ do |m, keywords|
    indexes = []
    quotes  = db["quotes"].find().to_a
    quotes.each_index do |idx|
      indexes << (idx + 1) unless quotes[idx]["quote"].downcase.index(keywords.downcase).nil?
    end
    if indexes.empty?
      m.reply "No quotes found."
    else
      m.reply "Quotes matching \"#{keywords}\": #{indexes}."
    end
  end
end

def get_quote(db, num)
  begin
    total = db["quotes"].count()
    quote = db["quotes"].find().to_a[num.to_i - 1]["quote"]
    "Quote (#{num}/#{total}): \"#{quote}\"."
  rescue
    "Quote not found."
  end
end

def get_karma(db, what)
  item  = db["karma"].find({"item" => what.downcase}).next
  karma = item.nil? ? 0 : item["karma"]
  "Karma for #{what}: #{karma}."  
end

def add_karma(db, what, how_much)
  item  = db["karma"].find({"item" => what.downcase}).next
  if item.nil?
    db["karma"].insert({"item" => what.downcase, "karma" => how_much})
  else
    karma = item["karma"].to_i + how_much
    db["karma"].update({"item" => what.downcase}, {"$set" => {"karma" => karma}})
  end    
end

bot.start