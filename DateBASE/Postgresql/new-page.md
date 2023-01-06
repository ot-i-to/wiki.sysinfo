---
title: Untitled Page
description: 
published: true
date: 2023-01-06T16:47:31.826Z
tags: 
editor: markdown
dateCreated: 2023-01-06T16:44:47.789Z
---

**FUNCTION: tel_convert(str_ text, rule_ text)**
##  
Допустимые символы и их описание rule_:

    ‘-’ - удаление цифры;
    ‘?’ - цифра/знак на данной позиции остается неизменной;
    ‘+’ - добавление последующих цифр/знаков;
    ‘!’ - окончание разбора, все дальнейшие цифры номера отрезаются;
    ‘0-9’, ‘буквы’, ‘#’ и ‘*’ (без знака +) - замещение цифры на данной позиции.

**Пример использования:**
`select tel_convert('AliBaba@sru.ru', '+0?8+32-54??79');
`вывод:` 0A83254ba79ru.ru`

**Где:** *исходный текст* - `'AliBaba@sru.ru'` *и правило / rule* - `'+0?8+32-54??79'`

> https://sysinfo.pro/ru/DateBASE/Postgresql/tel_convert
> 
{.is-info}
