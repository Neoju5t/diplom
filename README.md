# 🚀 Дипломный проект: отказоустойчивая инфраструктура в Yandex Cloud

## 📋 Описание

Проект представляет собой развёртывание отказоустойчивой инфраструктуры в Yandex Cloud с использованием **Terraform** и **Ansible**. Включает:

- Веб-сайт на двух серверах (nginx) с балансировкой нагрузки
- Мониторинг с помощью Zabbix (USE-метрики, пороговые значения)
- Сбор логов через Filebeat + Elasticsearch + Kibana
- Настроенные snapshot'ы всех дисков с ежедневным созданием и хранением 7 дней
- Безопасная сеть с bastion-хостом и приватными подсетями

## 🧰 Используемые технологии

- 🛠 Terraform
- ⚙️ Ansible
- 🧠 Zabbix
- 📦 Filebeat, Elasticsearch, Kibana
- 🐧 NGINX
- ☁️ Yandex Cloud

## 🖥️ Структура проекта

Terraform
├── ansible
│   ├── create_inventory.py
│   ├── group_vars
│   │   └── all.yml
│   ├── inventory
│   │   ├── output.json
│   │   └── production.yml
│   ├── roles
│   │   ├── elasticsearch
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   ├── filebeat
│   │   │   ├── files
│   │   │   │   └── filebeat-8.12.2.tar
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   │       └── filebeat.yml.j2
│   │   ├── kibana
│   │   │   ├── files
│   │   │   │   └── kibana-8.12.2.tar
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   │       ├── kibana-compose.j2
│   │   │       └── kibana-nginx.conf.j2
│   │   ├── nginx
│   │   │   ├── files
│   │   │   │   ├── images
│   │   │   │   │   └── logo.png
│   │   │   │   └── site
│   │   │   │       ├── about.html
│   │   │   │       ├── index.html
│   │   │   │       └── styles.css
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   └── main.yml
│   │   │   └── templates
│   │   │       └── default-site.j2
│   │   ├── zabbix_agent
│   │   │   ├── defaults
│   │   │   │   └── main.yml
│   │   │   ├── handlers
│   │   │   │   └── main.yml
│   │   │   ├── tasks
│   │   │   │   ├── main.yml
│   │   │   │   └── restart.yml
│   │   │   └── templates
│   │   │       └── zabbix_agentd.conf.j2
│   │   └── zabbix_server
│   │       ├── defaults
│   │       │   └── main.yml
│   │       ├── handlers
│   │       │   └── main.yml
│   │       ├── tasks
│   │       │   ├── ansible.cfg
│   │       │   └── main.yml
│   │       └── templates
│   │           ├── zabbix.conf.j2
│   │           └── zabbix_server.conf.j2
│   └── site.yml
├── main.tf
├── outputs.tf
├── providers.tf
├── scripts
│   ├── deploy.sh
│   └── verify.sh
├── snapshots.tf
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars
└── variables.tf

## 🌐 Архитектура

- Два веб-сервера (nginx) в разных зонах без внешних IP
- Application Load Balancer распределяет трафик
- Bastion host с публичным IP для SSH-доступа к приватным ВМ
- NAT-инстанс обеспечивает доступ в интернет из приватной сети
- ВМ мониторинга, логирования и визуализации в публичной подсети

## 🛡 Безопасность

- ВМ без внешнего IP, кроме bastion
- ProxyCommand в Ansible для доступа через bastion
- Настроены Security Groups
- Токены и чувствительные данные не хранятся в git

## 📊 Мониторинг (Zabbix)

- Установлен Zabbix Server + агенты на всех хостах
- Настроены дешборды по USE-модели:
  - CPU, RAM, Disk, Network
  - HTTP-запросы к веб-серверам
- Установлены threshold'ы (пороговые значения)

📷 _Пример Zabbix dashboard:_
![Zabbix Dashboard](./screenshots/zabbix_dashboard.png)

## 📑 Логирование (ELK)

- Filebeat на веб-серверах отправляет nginx `access.log` и `error.log` в Elasticsearch
- Kibana подключена к Elasticsearch

📷 _Пример Kibana dashboard:_
![Kibana](./screenshots/kibana.png)

## 💾 Резервное копирование

- Настроены snapshot'ы всех ВМ
- Создаются каждый день в 03:00 (UTC)
- Хранятся 7 дней

## ⚙️ Деплой

1. **Развёртывание инфраструктуры:**

cd terraform
terraform init
terraform apply

2. **Конфигурация ВМ:** 

cd ansible
python3 create_inventory.py > inventory/output.json
ansible-playbook -i inventory/output.json site.yml

3. **Создание снапшотов:**

📷 Скриншоты

Zabbix

Kibana

Сайт через балансировщик (curl)

Успешный terraform apply

📁 Дополнительно
Используется .ru-central1.internal DNS для подключения

Docker-образы загружены вручную (в связи с блокировкой docker.elastic.co)

Ansible запускается с Mac через bastion (указан ProxyCommand)
