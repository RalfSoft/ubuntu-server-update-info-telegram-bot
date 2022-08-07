#!/bin/bash

# Check if script is running as sudo
if [[ $UID != 0 ]]; then
    echo "Please run this script as sudo!"
    exit "1"
fi

echo "Checking if python3 and pip3 is installed"
if [ ! -f "/usr/bin/python3" ]; then
echo "Please install a python3 version!"
exit "1"
fi
if [ ! -f "/usr/bin/pip3" ]; then
echo "Please install python3-pip!"
exit "1"
fi

echo "Installing Python libraries"
pip3 install -r requirements.txt

if [ -d "/opt/ubuntu-server-update-info-telegram-bot" ]; then
    rm -r /opt/ubuntu-server-update-info-telegram-bot
    mkdir -p /opt/ubuntu-server-update-info-telegram-bot
else
    mkdir -p /opt/ubuntu-server-update-info-telegram-bot
fi

if [ -d "/var/log/ubuntu-server-update-info-telegram-bot" ]; then
    rm -r /var/log/ubuntu-server-update-info-telegram-bot
    mkdir -p /var/log/ubuntu-server-update-info-telegram-bot
else
    mkdir -p /var/log/ubuntu-server-update-info-telegram-bot
fi

echo "-------------------------------------------------------"
echo "Copying script..."
cp bot.py /opt/ubuntu-server-update-info-telegram-bot/bot.py
cp LICENSE /opt/ubuntu-server-update-info-telegram-bot/bot.py

echo "Define when the script should be executed using cronjob (no validation use https://crontab.guru/ for help)"

read -p "Cronjob minute: " cronjob_minute
read -p "Cronjob hour: " cronjob_hour
read -p "Cronjob day: " cronjob_day
read -p "Cronjob month: " cronjob_month
read -p "Cronjob weekday: " cronjob_weekday

if [ -f "/etc/cron.d/ubuntu-server-update-info-telegram-bot-cron" ]; then
    rm /etc/cron.d/ubuntu-server-update-info-telegram-bot-cron
    cron="$cronjob_minute $cronjob_hour $cronjob_day $cronjob_month $cronjob_weekday python3 /opt/ubuntu-server-update-info-telegram-bot/bot.py"
    echo "$cron" > /etc/cron.d/ubuntu-server-update-info-telegram-bot-cron
else
    cron="$cronjob_minute $cronjob_hour $cronjob_day $cronjob_month $cronjob_weekday python3 /opt/ubuntu-server-update-info-telegram-bot/bot.py"
    echo "$cron" > /etc/cron.d/ubuntu-server-update-info-telegram-bot-cron
fi

read -p "Please enter your Telegram-Bot API-Key: " telegram_bot_api_key
read -p "Please enter your Telegram chat ID: " telegram_bot_chat_id

echo TELEGRAM_BOT_API_KEY=$telegram_bot_api_key >> /etc/environment
echo TELEGRAM_CHAT_ID=$telegram_bot_chat_id >> /etc/environment

echo "Log directory is set to: /var/log/ubuntu-server-update-info-telegram-bot/bot.log"
echo "Successfully installed the ubuntu server update info telegram bot."