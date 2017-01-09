# HELPq-slackbot

A Slackbot that interfaces with [Edwin Zhang's HELPq](https://github.com/ehzhang/HELPq)! Written for SwampHacks 2017.

## End-User Guide

### Commands

This bot is fairly easy to use. You have the following commands:
- `.ticket create [topic]`: creates a ticket for mentors to see
- `.ticket delete`: deletes your ticket
- `.ticket get`: fetches your open ticket
- `.ticket help`: view these commands
- `.ticket [anything-else]`: fetches your open ticket

Due to requirements on HELPq, you are only allowed one ticket at a time. If you need to re-submit your ticket, please delete your ticket with `.ticket delete` and create a new one.

### Got an Error?

Please tell the admin of your Slack to check the logs and submit a ticket here! Thanks. :)

## Setting up HELPq-slackbot

### Requirements

- A special version of HELPq with an API that can be found here: [https://github.com/andrewjkerr/HELPq](https://github.com/andrewjkerr/HELPq).
- Ruby 2.3.0
- Bundler (`gem install bundler`)
- A Slack bot key!
- A HELPq special version API key that you will need to set in your special version of HELPq's config file.

### Installing

1. Clone this respository `git clone https://github.com/andrewjkerr/HELPq-slackbot.git`
2. `bundle install`
3. Rename `config/application.sample.yml` to `config/application.yml` and add your values
4. `ruby bot.rb`

## License

This repository is licensed under the [MIT license](https://github.com/andrewjkerr/HELPq-slackbot/blob/master/LICENSE.md).

## Contributing

Want to contribute? Great! Here's what you do:

1. Fork this repository
2. Push some code to your fork
3. Come back to this repository and open a PR
4. After some review, get that PR merged to master
5. Give yourself a pat on the back; you're awesome!

Feel free to also open an issue with any requests!
