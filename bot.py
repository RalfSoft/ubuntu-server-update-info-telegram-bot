from datetime import date, timedelta
from telegram import Bot
from time import sleep
import asyncio
import logging, requests, os, sys

logging.basicConfig(filename='/var/log/ubuntu-server-update-info-telegram-bot/bot.log', encoding='utf-8', level=logging.INFO, format='%(levelname)s:%(asctime)s:%(message)s')

API_KEY = str(os.getenv('TELEGRAM_BOT_API_KEY'))
CHAT_ID = os.getenv('TELEGRAM_CHAT_ID')
bot = Bot(API_KEY)

# Check if the Telegram API-Key is valid (make sure that Token isn't used by another script)
def check_API_KEY():
    api_url = 'https://api.telegram.org/bot' + API_KEY + '/getUpdates'
    response = requests.get(api_url, verify=True)
    if response.status_code != 200:
        return False
    else:
        return True

async def main():
    if check_API_KEY() == True:
        logging.info("TELEGRAM_BOT_API_KEY variable is valid")
    else:
        logging.error("TELEGRAM_BOT_API_KEY is not valid. Please check your TELEGRAM_BOT_API_KEY variable!")
        sys.exit(1)
    await check_reboot_required()
    await check_upgradeable_packages()
    await check_apt_history_log()

# Bot send method
async def send(_text):
    await bot.send_message(chat_id=CHAT_ID, text=_text)

async def check_reboot_required():
    try:
        reboot_required_file = "/var/run/reboot-required.pkgs"
        if os.path.isfile(reboot_required_file) == True:
            file = open(reboot_required_file, "r")
            data = file.read()
            file.close()
            send("Reboot is required due to\n" + data)
    except Exception as exception:
        await send("Error while checking for reboot required:\n " + str(exception))

async def check_upgradeable_packages():
    try:
        upgrades = os.popen('apt list --upgradeable').read()
        if upgrades != "Listing...\n":
            await send("Upgrades are available:\n" + str(upgrades))
    except Exception as exception:
        await send("Error while checking for upgrades:\n " + str(exception))

# Check apt history log of the last 2 days
async def check_apt_history_log():
    try:
        apt_history_log = "/var/log/apt/history.log"
        if os.path.isfile(apt_history_log) == True:
            file = open(apt_history_log, "r")
            data = file.readlines()
            file.close()
            line_number = 0
            start_date = str(date.today() - timedelta(days=1))
            search_string = 'Start-Date: ' + start_date
            message = ""
            for line in data:
                if search_string in line:
                        for i in data[line_number:-1]:
                            message += i
                        await send("apt history log of the last 2 days:\n" + message)
                        break
                line_number +=1
    except Exception as exception:
        await send("Error while checking for completed upgrades:\n " + str(exception))

if __name__ == "__main__":
    asyncio.run(main())
