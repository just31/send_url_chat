*** Settings ***
Documentation   Проверка перехода на страницу оплаты в разных языках
Library         SeleniumLibrary



*** Variables ***
${BROWSER}      chrome
# headlesschrome
*** Keywords ***
Check ekvaring
    [Arguments]     ${url}
    Open Browser On The Index Page  ${url}
    Run Keyword And Ignore Error    Close Cookie Window               # Нажимаем на кнопку закрыть куки игнорируя ошибки
    Проверяем Наличие Раскладки языков на странице      ${url}
    [Teardown]    Close Browser                                      # Закрываем браузер и завершаем тест

#---------------------ОТКРЫВАЕМ БРАУЗЕР-----------------------
Open Browser On The Index Page
    [Arguments]     ${url}
    Open Browser    ${url}      ${BROWSER}
    Set Window Size     1600	900
    # Maximize Browser Window
    # -------------Нажимаем на кнопку закрыть куки -------
Close Cookie Window
    Click Element    xpath: //div[@class="cookies__close"]
    Sleep    5  # Sleep to hide cookie window
    #-------Проверяем список событий и наличие элементов на странице. Кликаем на первый элемет списков

#-----------------language--stert----------------
Проверяем Наличие Раскладки языков на странице
    [Arguments]     ${url}
    ${language_index}=  Run Keyword And Return Status  Page Should Contain Element  xpath: //div[contains(@class,'header_wr')]//form[contains(@class,'active')]
    Run Keyword If      not ${language_index}      Click First Events on The Events List With Tcikets  ${url}
     ...             ELSE       Click_Language      ${url}

Click_Language
    [Arguments]     ${url}
    Click First Events on The Events List With Tcikets  ${url}
    Go to     ${url}
    Click Element   xpath: //div[contains(@class,'header_wr')]//form[contains(@class,'active')]
    @{lits_language}      Get WebElements        xpath: //div[@class='header transparent']//form[*]//input[3]
    ${finish}   Get Element Count   xpath: //div[@class='header transparent']//form[*]//input[3]
    FOR   ${index}    IN RANGE   1  ${finish}   1
    \       @{lits_language}      Get WebElements        xpath: //div[@class='header transparent']//form[*]//input[3]
    \       ${HREF}     Get Element Attribute    ${lits_language}[${index}]       attribute=value
    \       Go to     ${url}/${HREF}/
    \       Click First Events on The Events List With Tcikets  ${url}
    \       Go to     ${url}
    END
#-----------------language--end----------------

Click First Events on The Events List With Tcikets                  # Кликаем на первый элемет списка- "Оформить заказ"
    [Arguments]     ${url}
    Click Element	xpath: //a[@data-test="select_event"][1]
    Choose Ticket                                                       # Выбираем активный билет
    Click Order Button                                                  # Проверяем активность поля и кликаем "Оформить заказ" на странице билетов
    Fill And Send Order      ${url}                                                 # Заполняем тестовые данные и выбираем вид заказа - "Доставка курьером"


Choose Ticket                                                # Выбираем активный билет "на схеме"
    ${scheme_class} =   Get Element Attribute   xpath: //div[@data-test="scheme-scenario"]      class
    Run keyword if  'active' in '${scheme_class}'   Choose Ticket on Scheme             #----выбираем на схеме
    ...             ELSE    Choose Ticket on List                                       #----выбираем списком
        #-------------------ПРОВЕРКА НАЛИЧИЯ ЭЛЕМЕНТА---
Choose Ticket on Scheme                                                                 #----выбираем на схеме - делим на типы
    ${scheme_sectors}=  Run Keyword And Return Status  Page Should Contain Element  xpath: //svg:g[@class="active" and @data-tooltip_scheme]
    Run Keyword If    ${scheme_sectors}  Choose Ticket on Scheme sectors    ELSE    Choose Ticket on Scheme main

Choose Ticket on Scheme sectors
    Wait Until Element Is Enabled   xpath: //svg:g[@class="active" and @data-tooltip_scheme][last()]     10
    Click Element   xpath: //svg:g[@class="active" and @data-tooltip_scheme][last()]
    Wait Until Element Is Enabled   xpath: //*[@data-id and @class="active"]     10
    Click Element   xpath: //*[@data-id and @class="active"][1]

Choose Ticket on Scheme main
    Wait Until Element Is Enabled       xpath: //*[@data-id and @class="active"][1]     10
    Click Element       xpath: //*[@data-id and @class="active"][1]
    # Если поле оформить заказ не появилось, то кликаем по билету ещё раз
    Wait Until Element Is Enabled   xpath: //*[@data-id and @class="active"][1]     10
    ${sport}=  Run Keyword And Return Status  Page Should Contain Element  xpath: //a[@data-test="order-button"]
    Run Keyword If    not ${sport}  Click Element   xpath: //*[@data-id and @class="active"][1]
    Wait Until Element Is Enabled   xpath: //*[@data-id and @class="active"][1]     10
    ${sport}=  Run Keyword And Return Status  Page Should Contain Element  xpath: //a[@data-test="order-button"]
    Run Keyword If    not ${sport}  Click Element   xpath: //*[@data-id and @class="active"][1]


Choose Ticket on List
    Click Element   xpath: //div[@class="map__right-wrp"]/div[@data-id][1]

    Wait Until Element Is Enabled   xpath: //div[@class="map__right-wrp"]/div[@data-id][1]//div[@data-row and @class="row__wrp"][1]     10
    Click Element   xpath: //div[@class="map__right-wrp"]/div[@data-id][1]//div[@data-row and @class="row__wrp"][1]

    Wait Until Element Is Enabled   xpath: //div[@class="map__right-wrp"]/div[@data-id][1]//div[@data-row and @class="row__wrp active"][1]//div[@data-ticket]       10
    Click Element   xpath: //div[@class="map__right-wrp"]/div[@data-id][1]//div[@data-row and @class="row__wrp active"][1]//div[@data-ticket]

Click Order Button                          # Проверяем активность поля "Оформить заказ" и кликаем "Оформить заказ" на странице билетов
    Wait Until Page Contains Element     xpath: //div[@id="cartBottom" and @class="cart-bottom active"]     5
    Sleep   1
    Click Element   xpath: //a[@data-test="order-button"]

Fill And Send Order                         # заполняем тестовые данные и выбираем вид заказа - "Доставка курьером"
    [Arguments]     ${url}
    Input Text      xpath: //input[@data-test="name"]       Functional Test
    Input Text      xpath: //input[@data-test="surname"]    Test
    Press Keys      xpath: //input[@data-test="phone"]      1111234567
    Input Text      xpath: //input[@name="email"]           test@test.com
    Sleep   2
    Press_Url   ${url}                                                  # Проверяем осуществился ли переход на страницу эквайринга
    Click Element   xpath: //div[@class='form-cart__submit']          # Применить

Press_Url
    [Arguments]     ${url}
    ${url_page}=    Get Location
    ${language_index}=  Run Keyword And Return Status  Page Should Contain Element  xpath:  //div[@class='wrapper_1560 wrapper_1560-head']/div[@class='header__search']/*[1]
    Run Keyword If      ${language_index}       Send bad url     ${url_page}   ELSE         Success ekvaring      ${url_page}

Send bad url
    [Arguments]     ${url}
    Log	          На данном сайте: перехода на эквайринг не было    WARN
    Set Suite Variable     ${FELL_HERE}    ${url}
    Sleep   2


Success ekvaring
   [Arguments]     ${url}
   Log            На данном сайте: переход на эквайринг произошел
   Set Suite Variable     ${FELL_HERE}     ${url}
   Sleep   2

#----------------------------end---------------
