# Дипломная работа по профессии «Системный администратор - Динейко Алексей

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
```bash
cd terraform
terraform init
terraform apply
```
2. **Конфигурация ВМ:** 
```bash
cd ansible
python3 create_inventory.py > inventory/output.json
ansible-playbook -i inventory/output.json site.yml
```
3. **Создание снапшотов:**

## 📷 Скриншоты

Zabbix

Kibana

Сайт через балансировщик (curl)

Успешный terraform apply

## 📁 Дополнительно
Используется .ru-central1.internal DNS для подключения

Docker-образы загружены вручную (в связи с блокировкой docker.elastic.co)

Ansible запускается с Mac через bastion (указан ProxyCommand)
