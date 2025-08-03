# GitManager

## Что это и зачем?

Основная цель - дать пользователю простой и удобный интерфейс для работы с кодом 1С по методологии Git Flow. GitManager полностью берет на себя всё взаимодействие с репозиториями Git, организует ведение задач в разных ветках, автоматизирует сборку и разборку конфигураций 1С из исходников.


Решение построено на БСП и состоит из 3 компонентов:
* GitManager 
* GitAgent (Опционально)
* Cli приложение (https://github.com/Untru/pivo-cli)


GitManager и GitAgent это одна конфигурация, которую можно продублировать если базы расположены на разных серверах. Идея сделать GitAgent родилась из-за того, что по сети сборка и разборка исходников работает очень долго. Поэтому основная база, на которую подключен GitManager, отправляет команды в GitAgent, а он уже запускает скрипты. Работать возможно и без GitAgent, для этого надо установить константе `СтратегияЗапускаСкрипта` значение `CMD`

Общая схема работы:

```mermaid
sequenceDiagram
    participant GitManager as GitManager (Сервер 1)
    participant GitAgent as GitAgent (Сервер 2)
    participant PIVO-CLI as CLI (Сервер 2)

    GitManager ->> GitAgent: Отправка команды (pivo-cli)
    activate GitAgent
    GitAgent ->> CLI: Запуск команды
    activate CLI
    CLI -->> GitAgent: Результат (stdout/stderr)
    deactivate CLI
    GitAgent -->> GitManager: Ответ (логи/статус)
    deactivate GitAgent
```


## Старт работы

Для удобства работы мы сделали скрипт по разворачиванию базы (РазворачиваниеБазы.bat)

Необходимо заполнить переменные, система сама скачает файл с репозитория и развернет базу на сервере.
Основные тесты были с серверной базой, по этому работа в файловой базе не гарантируется.

<details>
 <summary><strong> Скрипт </strong></summary>


```bat
@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =============================================
:: Установка GitManager
:: =============================================

:: Параметры
set "GITHUB_URL=https://github.com/Untru/gitmanager/releases/latest/download/GitManager.cf"
set "TEMP_FILE=%TEMP%\GitManager.cf"
set "DB_SERVER=localhost"  :: Измените на свой сервер СУБД при необходимости
set "DB_NAME=Name"         :: Имя новой базы данных
set "DB_USER=postgres"     :: Пользователь СУБД
set "DB_PWD=postgres"      :: Пароль пользователя СУБД
set "1C_USER=Администратор" :: Пользователь 1С
set "1C_PWD=""             :: Пароль 1С (оставьте пустым, если без пароля)
set "V8VER=8.3.27.1508"    :: Версия 1С


:: Скачиваем файл
echo Скачивание GitManager.cf...
curl -L -o "%TEMP_FILE%" "%GITHUB_URL%"
if %errorlevel% neq 0 (
    echo Ошибка при скачивании файла.
    pause
    exit /b 1
)
echo OK. 1cv8 найден.
pause

:: Создаём и загружаем базу
echo Создание базы данных...
"%ProgramFiles%\1cv8\%V8VER%\bin\1cv8.exe" createinfobase Srvr=%DB_SERVER%;Ref=%DB_NAME%;SQLSrvr=%DB_SERVER%;DBMS=PostgreSQL;SQLDB=%DB_NAME%;SQLUID=%DB_USER%;SQLPwd=%DB_PWD%;CrSQLDB=y;DB=%DB_NAME% /AddInList %DB_NAME% /UseTemplate "%TEMP_FILE%" /Out"CreateDB-%1.log"
@TYPE "CreateDB-%1.log"

if %errorlevel% neq 0 (
    echo Ошибка при создании базы данных.
    pause
    exit /b 1
)

:: Удаляем временный файл
del "%TEMP_FILE%"

echo База данных "%DB_NAME%" успешно создана и добавлена в список баз.
pause
```
Запустить и наслаждаться
</details>

Разработанный "Начальный помощник" (Управление разработкой -> Запуск) позволяет легко начать использование нашей программы.
Советую пройтись по всем шагам и, заодно, изучить структуру объектов. В нём предусмотренны: заполнение пользователей, создание проекта, добавление баз и установка oscript.

<img src="images/image-7.png" width="600" alt="Начальный помощник">

<img src="images/image-8.png" width="600" alt="Настройки помощника">

<details>
 <summary><strong> Если хотим все заполнять сами </strong></summary>
Необходимо выполнить следующие действия:

1. Cоздать пользователя с правами "Администратор"

<img src="images/image-1.png" width="600" alt="Настройки пользователя">

2. Создать и заполнить Проект

<img src="images/image-3.png" width="600" alt="Проект">

3. Заполнить "Настройки пользователя". Обязательно необходимо указать Проект, токен от внешнего репозитория, а так же почту пользователя

<img src="images/image-2.png" width="600" alt="Настройки пользователя">

4. Заполнить настройки базы

5. Создать репозиторий, нажав на соответствующую кнопку

<img src="images/image-4.png" width="600" alt="Создание репозитория">

6. Проверить, что у службы под которой запущена 1С есть права на расшаренную папку

<img src="images/image-5.png" width="600" alt="Права доступа">

</details>

Необходимо запустить RAC как службу, для этого есть свой скрипт
<details>
 <summary><strong> Скрипт добавления службы RAS </strong></summary>

``` bat 
@echo off
rem %1 - полный номер версии 1С:Предприятия
set SrvUserName=.\USR1CV8
set SrvUserPwd="c2o3"
set CtrlPort=1540
set AgentName=localhost
set RASPort=1545
set SrvcName="1C:Enterprise 8.3 Remote Server 26"
set BinPath="\"C:\Program Files\1cv8\8.3.26.1540\bin\ras.exe\" cluster --service --port=%RASPort% %AgentName%:%CtrlPort%"
set Desctiption="1C:Enterprise 8.3 Remote Server 26"
sc stop %SrvcName%
sc delete %SrvcName%
sc create %SrvcName% binPath= %BinPath% start= auto obj= %SrvUserName% password= %SrvUserPwd% displayname= %Desctiption%
```
</details>

Для работы с гитхаб необходимо установить [GitHub CLI](https://cli.github.com/)

## Процесс работы

Каждой базе должна соответствовать своя папка, подключенная к репозиторию. Это можно проверить по наличию кнопки создания репозитория

![alt text](images/image-11.png)


### Создаем задачу

![alt text](images/image-10.png)

Тут есть 3 варианта:

* Новая задача - создается новая ветка из ветки Develop
* HotFix к задаче - создается новая ветка для задачи из ветки main/master, создает новую задачу к текущей
* HotFix новая задача - ??? требует наличие задачи в таск трекере

В результате задача должна появиться в списке, прошу обратить внимание на кнопки:

![alt text](images/image-13.png)

### Таск трекеры

Сейчас поддерживается 2 таск трекера 
#### 1С (только простая загрузка задач)

  Передаем параметр - номер задачи

```curl
curl --location 'https:/Путь К Базе/hs/tasks/task?id=000000002'
```

В ответ мы ожидаем получить JSON

```json
{
  "Исполнитель": "",
  "Трудозатраты_часов": 0,
  "Статус": "",
  "ДатаПринятияВРаботу": "",
  "Описание_Задачи": "",
  "Описание_Решения": "",
  "Приоритет": ,
  "Очередь": 
}
```
#### Битрикс 


### Переходим на ветку

Во время перехода, репозиториий базы переключается на выбранную в списке ветку задачи, далее происходит загрузка в базу:
* Основной конфигурации, если стоит галочка

 ![alt text](images/image-12.png)

* Загрузка расширений указанных в задаче
* Компилирование внешних обработок и помещение их в папку проекта. `\Repositories\ИмяБазы\build\epf`

### Зафиксировать изменения

Разбор объектов указанных в задаче на исходники (Конфигурация и расширения). 
Разбор внешних обработок/отчетов происходит из папки `build\epf`

### Создание мердж реквеста
В случае если это GITHUB - необходим GITHUB-CLI


### Другие возможности
* Создание новых внешних обработоток по шаблону
* Загрузки обработок в бд 
* Подготовка релиза и быстрое обновление баз
* Управление списком задач в виде канбан доски
* Анализ сделанных коммитов

### Получение расширенных логов
Для вывода логов от 1commands (Блиблиотека запуска команд https://github.com/artbear/1commands)
Мы можем задать переменную окружения

``` bat 
set LOGOS_CONFIG=logger.oscript.lib.commands=DEBUG;
```
Или добавить команды, которые будут запускаться перед основными

<img src="images/image-9.png" width="600" alt="Запуск команд">

# ВАЖНО
Так как инзначально инструмент разрабатывался для нужд компании и подгонялся под внутренние требования, некоторый функционал не оттестирован в парадигме универсальности.

Если вы захотите развернуть инструмент у себя и что-то не получается - смело пишите. Обращайтесь за помощью, любые ваши вопросы помогут дописать руководство и поправить найденные замечания.

Так же, всячески приветствуются issues.


Использование опенсорс библиотек
- ОПИ (https://github.com/Bayselonarrend/OpenIntegrations)
- GitCodeReview (https://github.com/salexdv/git_code_reviews)
- КоннекторHTTP ()
- Oscript (autumn, autumn-cli, autumn-logos, 1connector, v8rac, v8runner, gitrunner, ibcmdrunner)

ОГРАНИЧЕНИЯ !!! Некоторый функционал не работает в WEB Клиенте