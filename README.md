# Задание

Настроить управление конфигурацией проекта через salt.

# Подготовка к запуску

Публичный ключ должен находиться по пути: ```~/.ssh/id_rsa.pub```

В системе должен быть установлен terraform. Тестировалось на версии terraform v1.6.6.

# Настройка и запуск

* склонировать репозиторий;
* настроить подключение к облаку яндекс. Для этого перейти в каталог ```terraform``` создать файл ```yc.auto.tfvars``` с содержимым (подставить свой токен, id облака и каталога):

```
yc_token     = токен
yc_cloud_id  = id облака
yc_folder_id = id каталога
```

* инициализировать терраформ: ```terraform init```;
* запустить создание инфраструктуры: ```terraform apply```;
* после создания инфраструктуры дождаться загрузки ВМ;
* подключиться к salt-master по ssh (ip-адрес будет в terraform output);
* дождаться подключения миньонов. Для этого периодически выполнять команду: ```salt-key -L```;
* принять ключи миньонов командой: ```salt-key -A```
* дождаться применения миньонами состояний;
* перейти в браузере на адрес балансировщика (ip-адрес будет в terraform output).

# Пояснения

Процесс развертывания окружения при помощи terraform и демонстрация работоспособности записаны на видео.
Видео доступно по ссылке: https://disk.yandex.ru/i/jkzXX2r0ZroWDg

* инфраструктура проекта взята из [задания 2](https://github.com/aglumov/otus_task_4_nginx) (Настраиваем балансировку веб-приложения):
  * ```lb0-1```: балансировщик (nginx);
  * ```app0-1```: сервера веб-приложения (Wordpress);
  * ```db0```: база данных веб-приложения (mariadb);
* начальная настройка выполняется при помощи cloud-init:
  * установка SaltStack на мастера и миньонов;
  * копирование конфигурационных файлов;
  * настройка hostname;
  * добавление пользователей и ssh-ключей;
* манифесты для Salt (формулы и пиллары) находятся в одноименном каталоге данного репозитория;
* репозиторий подключен при помощи gitfs.
