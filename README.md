Bluebot
=======

**An IRC bot that runs on Heroku.**


Bluebot is written in Ruby using the [Cinch IRC framework](https://github.com/cinchrb). You can easily customize it by using many existing [Cinch plugins](https://rubygems.org/search?utf8=%E2%9C%93&query=cinch) or by writing your own.

It requires a single Dyno and uses the free [MongoHQ](https://addons.heroku.com/mongohq) add-on as its persistence backend, which means you can essentially run Bluebot on Heroku for free, forever.


Features
--------

- URL title scraping.
- Karma system.
- Quotes manager.
- Ability to respond as [Cleverbot](http://www.cleverbot.com/).
- Wikipedia and Urban Dictionary plugins.


Supported commands
------------------

### Karma system ###

* `!karma` prints your current karma.
* `!karma <foo>` prints the current karma for `<foo>`.
* `<foo>++` increments karma for `<foo>`.
* `<foo>--` decrements karma for `<foo>`.

### Quotes manager ###

* `!addquote <quote>` records a new quote.
* `!quote` prints a random quote.
* `!quote <number>` prints quote with index `<number>`.
* `!lastquote` prints the last quote recorded.
* `!searchquote <keywords>` prints the quotes matching `<keywords>`.

### Respond as Cleverbot ###

Talk to the bot by prefixing your messages with the bot's nickname and it shall respond as Cleverbot.

Example:

```
    <Louie> Bluebot: What's the Answer to the Ultimate Question of Life, the Universe and Everything?
  <Bluebot> Louie: 42.
```

### Wikipedia ###

* `!wiki <query>` searches Wikipedia for `<wiki>`.

### Urban Dictionary ###

* `!ud <query>` searches Urban Dictionary for `<query>`.


Deployment instructions
-----------------------

1. Set up a new [Heroku](http://heroku.com/) app and add the free [MongoHQ](https://addons.heroku.com/mongohq) Sandbox add-on.

  ```
  cd Bluebot
  heroku create
  heroku addons:add mongohq:sandbox
  ```

2. Tell Bluebot where to connect, what nickname to use, and optionally the required password to identify against the network's NickServ service.

  ```
  heroku config:set BLUEBOT_SERVER=irc.myserver.com
  heroku config:set BLUEBOT_CHANNEL=#mychannel
  heroku config:set BLUEBOT_NICK=mybluebot
  heroku config:set BLUEBOT_PASSWORD=password         # Optional  
  ```

3. Push the code.

  ```
  git push heroku master
  ```

4. Launch Bluebot.

  ```
  heroku scale bluebot=1
  ```

You can later shut down the bot by running `heroku scale bluebot=0` and relaunch it by running `heroku scale bluebot=1`.


Local development
-----------------

As you start customizing the bot and adding new featuers, you'll want to test these changes in your local development environment. In order to do this, you'll have to:

1. Launch a local MongoDB server.

  ```
  sudo service mongodb start          # Ubuntu
  sudo /etc/init.d/mongodb start      # Debian
  systemctl start mongodb             # Arch Linux
  ```

2. Launch Bluebot.

  ```
  ruby bluebot.rb
  ```

By default, Bluebot connects to `irc.freenode.net #cinch-bot` using the nickname `bluebot`. You can override this by exporting the necessary global variables (see deployment instructions), e.g.: `BLUEBOT_NICKNAME=mybot ruby bluebot.rb`.
