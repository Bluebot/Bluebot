require "cinch"
require "cinch/plugins/urlscraper"

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