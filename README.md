# Дипломная работа по профессии «Системный администратор» - Динейко Алексея

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

- ВМ без внешнего IP, кроме bastion, kibana и zabbix
- ProxyCommand в Ansible для доступа через bastion
- Настроены Security Groups
- Токены и чувствительные данные не хранятся в git

## 📊 Мониторинг (Zabbix)

- Установлен Zabbix Server + агенты на всех хостах
- Настроены дешборды по USE-модели:
  - CPU, RAM, Disk, Network
  - HTTP-запросы к веб-серверам
- Установлены threshold'ы (пороговые значения)

## 📑 Логирование (ELK)

- Filebeat на веб-серверах отправляет nginx `access.log` и `error.log` в Elasticsearch
- Kibana подключена к Elasticsearch

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

## 📷 Скриншоты

Zabbix
![Скриншот-0](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2017.52.10.png)
![Скриншот-1](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2018.00.40.png)
Kibana
![Скриншот-2](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2017.52.16.png)
![Скриншот-3](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2018.01.58.png)
Сайт через балансировщик (curl + браузер)
![Скриншот-4](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2018.03.41.png)
![Скриншот-5](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2018.02.09.png)
Успешный terraform apply
![Скриншот-6](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2017.58.41.png)
Снимки дисков
![Скриншот-7](https://github.com/Neoju5t/diplom/blob/7b6afd2a70291c634e897942e56a1a47691843f7/scr/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-08-05%20%D0%B2%2018.06.30.png)
## 📁 Дополнительно
Используется .ru-central1.internal DNS для подключения

Docker-образы загружены вручную (в связи с блокировкой docker.elastic.co)

Ansible запускается с Mac через bastion (указан ProxyCommand)
