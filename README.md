# Ubuntu server update info with a Telegram-Bot

**This bot is only convinient if you have enabled unattended updates/upgrades for apt.**

This bot will send messages for:

* upgradeable apt-packages
* apt-packages which require a reboot
* apt history log of the last 2 days (Installs and Upgrades)

To start:

* ```git clone https://github.com/RalfSoft/ubuntu-server-update-info-telegram-bot.git```
* ```cd ubuntu-server-update-info-telegram-bot && sudo chmod 754 install.sh && sudo ./install.sh``` to install the bot.
* check that your Telegram-Bot API-key isn't used by another script.
* https://api.telegram.org/botYOUR_TELEGRAM_BOT_API_KEY/getUpdates should return:

```ok: true```
