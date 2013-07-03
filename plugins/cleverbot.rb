# Extracted from:
# https://github.com/caitlin/cinch-cleverbot/blob/master/lib/cinch/plugins/cleverbot.rb

require 'cinch'

module Cinch
  module Plugins
    require 'cleverbot'

    class CleverBot
      include Cinch::Plugin

      match lambda { |m| /#{m.bot.nick}[\s\p{Punct}]+(.+)/i }, use_prefix: false

      def initialize(*args)
        super

        @cleverbot = Cleverbot::Client.new
      end

      def execute(m, message)
        msg_back = @cleverbot.write message
        m.reply msg_back, true
      end

    end
  end
end