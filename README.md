# Что нужно для запуска
- docker версии не ниже 23.0.5
- docker-compose версии не ниже 1.25.0
- утилита make
- убедиться, что порты 3000 и 5432 не заняты

# Как запускать
В корне проекта необходимо выполнить:
```sh
make
```
После чего положить в корень файл с логами с именем `out` и выполнить
```sh
make fill_db
```
Затем при переходе по [ссылке](http://localhost:3000) будет доступно веб-приложение для поиска логов.

# Как все работает
Приложение состоит из 2 контейнеров:
- `web_gpb` - контейнер с веб-приложением для поиска логов
- `psql_gpb` - БД, в которую ходит веб-приложение

# Какие команды есть в Makefile
- `build` - собирает образы БД и веб-приложения
- `test` - запускает все тесты
- `fill_db` - заполняет БД на основе файла. Файл лога обязан иметь имя `out` и лежать в коне проекта для заполнения БД.
- `stop` - остановить все контейнеры
- `rm` - снести все контейнеры