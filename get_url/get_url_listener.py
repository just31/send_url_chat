import logging
from robot.libraries.BuiltIn import BuiltIn
from urllib.parse import urlparse
import telebot

from robot.model.keyword import Keywords
from robot.model.testcase import TestCases
from robot.running.model import TestCase, Keyword

ROBOT_LISTENER_API_VERSION = 3
logger = logging.getLogger(__name__)

TOKEN = 'YOUR_TOKEN_BOT'
CHAT = 'ID_PRIVATE_CHAT'


def send_msg_to_telegram_channel(message):
    bot_token = TOKEN
    chanel_id = CHAT
    bot = telebot.TeleBot(bot_token)
    try:
        msg = message
        bot.send_message(chanel_id, msg, parse_mode='html', disable_web_page_preview=True)
    except Exception as e:
        pass


def start_suite(suite, result):
    sites = ['https://testsite.com']

    test_cases = TestCases(parent=suite)

    for site_url in sites:
        BuiltIn().import_resource('${EXECDIR}/get_url/resource_get_url.robot')
        keyword_result = BuiltIn().run_keyword('Check ekvaring', site_url)

        if BuiltIn().get_variable_value('${FELL_HERE}') != "":
            test_url = BuiltIn().get_variable_value('${FELL_HERE}')
            test_url_host = urlparse(test_url).hostname
            text_from_telegramm = f"сайт на котором не произошел переход на эквайринг: https://{test_url_host}"
            print(f"сайт на котором не произошел переход на эквайринг: https://{test_url}")

            send_msg_to_telegram_channel(text_from_telegramm)

        # Создаем Keyword и записываем в список Keywords
        ks = Keywords()
        ks.append(Keyword(name='Check ekvaring', args=(site_url,)))

        # Создаем TestCase с нужным именем и добавляем к нему созданный Keyword
        test_case = TestCase(name=f'Test Check ekvaring on {site_url}', tags="Проверка переход на эквайринг")
        test_case.keywords = ks

        # Добавляем TestCase к TestCases
        test_cases.append(test_case)

    # Добавлем созданный список TestCases к текущему TestSuite
    suite.tests.extend(test_cases)
