---
title: Скрипт листа IP Российской зоны
description: Самообучающийся скрипт получения списка IP адресов Российской зоны для IPSET
published: true
date: 2023-01-23T19:14:38.221Z
tags: iptables, bash, shell, ipset, script, firewall, ru, inet, jq, whois, self-learning
editor: markdown
dateCreated: 2023-01-23T11:21:59.186Z
---

---

**_Файлы_:**

**/etc/RU/..**
***load\_russian\_ip.ru*** .... загрузка ip масок с RIPE
***ipcalc.pl*** ............... служебная программа ip-калькулятора для load\_russian\_ip.ru
***ipset.cron*** .............. сохранение настроек ipset  и перезапуск скрипта в случае падения
***ipset.logrotatie*** ........ ротация логов
***iptabless.sh*** ............ iptables правило
***start.sh*** ................ запуск авто-обновления Росииских масок в ipset
***whois.sh*** ................ служебная программа для start\_tail.sh
**/etc/RU/soft/CentOS-6**
       ***ipset-6.11-4.el6.x86\_64.rpm***
       ***jq-1.3-2.el6.x86\_64.rpm***
       ***libmnl-1.0.2-3.el6.x86\_64.rpm***
       ***whois-5.5.1-1.el6.x86\_64.rpm***
       ***whois-nls-5.5.1-1.el6.noarch.rpm***