
## Описание
Сборка и запуск 1С с файловыми базами в docker контейнере. Доступ к базам через http.
Возможен https, если у вас есть своё доменное имя.

## Содержание
- [Сборка образа](#Сборка-образа)
    - [Необходимые файлы](#Необходимые-файлы)
    - [Использование](#Использование)
- [Перенос образа на сервер](#Перенос-образа-на-сервер)
- [Запуск конейнера](#Запуск-конейнера)
    - [https](#https)

### Необходимые файлы
Для создания docker образа с portal.1c.ru необходимо скачать установочный файл платформы для linux, нужной вам версии.

```bash
setup-full-8.3.23.2040-x86_64.run
```
### Использование

Клонируем репозиторий и копируем установочный файл платформы 1с для linux

```bash
git clone https://
...
image_build [master●] ls -1
build.sh # Скрипт сборки образа
Dockerfile
nethasp.ini # Файл сведений для получения hasp лицензий
publish1c.sh # Скрипт публикации баз 1С на веб сервере
setup-full-8.3.23.2040-x86_64.run # Установочный файл платформы 1с
```
#### Редактируем Dockerfile

```dockerfile
...
ARG SETUP_1C_FILE=setup-full-8.3.23.2040-x86_64.run # Установочный файл платфоры 1c для linux
...
```
#### Запускаем сборку образа
Скрипт `build.sh` соберёт docker образ из Dockerfile'а и сохранит его в tar архив.
Перед запуском скрипта укажите релиз 1С для тега образа.

```bash
...
RELEASE="8_3_23_2040" # Укажите вашу версию платформы 1с
...
```
Будет создан файл образа контейнера

```bash
onec_file_8_3_23_2040.tar
```
# Перенос образа контейнера на сервер
Для запуска контейнера на другом сервере необходимо скопировать файл созданого образа и выоплнить команду

```bash
docker load --input onec_file_8_3_23_2040.tar
```

# Запуск конейнера

## docker

### http

```bash
docker run -p 8088:80 -v /path/to/bases:/infobases --name onec_file -d onec_file:8_3_23_2040
```


## docker-compose

```docker-compose
version: "2.1"
services:
  onec_file:
    image: onec_file:8_3_23_2040 # Укажите имя образа
    container_name: onec_file_8_3_23_2040 # Имя контейнера
    environment:
      # NH_SERVER_ADDR: 192.168.122.242 укажите ip адрес hasp сервера, если вы используете hasp ключи
      USER: 1000 # uid пользователя с полными правами доступа на директорию с базами 1с
      GROUP: 998 # gid пользователя с полными правами доступа на директорию с базами 1с
    ports:
      - 8088:80/tcp
    volumes:
      - /path/to/bases:/infobases
    restart: unless-stopped
```
# https
Если у вас есть своё доменное имя возможно использовать https. Получение бесплатного сертификата Let's Encrypt осуществляется через certbot на 90 дней. По истечении 90 дней необходимо будет снова получить сертификат.

### https

```bash
docker run -p 4443:443 -v /path/to/bases:/infobases --name onec_file -d onec_file:8_3_23_2040 && \
docker exec -it onec_file /usr/bin/certbot run \
    -d mydomain.ru \ # Ваш домен
    -a manual \
    --email email@example.com \ # Ваш адрес электронной почты
    --no-eff-email \
    --agree-tos \
    --preferred-challenges dns \
    -i apache
```
### docker-compose

```docker-compose
version: "2.1"
services:
  onec_file:
    image: onec_file:8_3_23_2040 # Укажите имя образа
    container_name: onec_file_8_3_23_2040 # Имя контейнера
    environment:
      # NH_SERVER_ADDR: 192.168.122.242 укажите ip адрес hasp сервера, если вы используете hasp ключи
      USER: 1000 # uid пользователя с полными правами доступа на директорию с базами 1с
      GROUP: 998 # gid пользователя с полными правами доступа на директорию с базами 1с
    ports:
      - 4443:443/tcp
    volumes:
      - /path/to/bases:/infobases
    restart: unless-stopped
```
После запуска docker контейнера необходимо выполнить команду для запуска получения сертификата через certbot

```bash
docker exec -it onec_file /usr/bin/certbot run \
    -d mydomain.ru \ # Ваш домен
    -a manual \
    --email email@example.com \ # Ваш адрес электронной почты
    --no-eff-email \
    --agree-tos \
    --preferred-challenges dns \
    -i apache
```

# Требования к хранению баз

1. Названия директорий должны быть латиницей и без пробелов.
2. Все базы находятся на певром уровне подключаемой директории, никаких вложенных директорий с базами быть не должно.
