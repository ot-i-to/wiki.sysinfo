---
title: Untitled Page
description: 
published: true
date: 2023-03-21T18:26:45.152Z
tags: 
editor: markdown
dateCreated: 2023-03-21T18:26:45.152Z
---

[[Category:Sound (Русский)]]
[[en:PulseAudio/Troubleshooting]]
[[ja:PulseAudio/トラブルシューティング]]
{{TranslationStatus (Русский)|PulseAudio/Troubleshooting|8 декабря 2017|500154}}
Смотрите основную статью [[PulseAudio (Русский)]].

== Звук ==

Здесь Вы найдете некоторые подсказки по проблемам звука и почему Вы ничего не можете услышать.

=== Автоматический бесшумный режим ===

Автоматический бесшумный режим может быть включен изначально. Его можно легко отключить с помощью {{ic|alsamixer}}.

Для подробностей смотрите https://superuser.com/questions/431079/how-to-disable-auto-mute-mode 

Для сохранения текущих настроек, как опций по умолчанию, выполните от имени суперпользователя (root) {{ic|alsactl store}}

=== Аудиоустройство с отключенным звуком ===

Если нет звука при использовании [[ALSA]], попытайтесь включить звуковую карту. Чтобы сделать это, запустите {{ic|alsamixer}}, и убедитесь, что каждый столбец имеет под ним зелёное значение {{ic|00}}  (можно переключать путём нажатия {{ic|m}}):

 $ alsamixer -c 0

{{Note (Русский)| alsamixer не скажет Вам, какое устройство вывода установлено как значение по умолчанию. Одна из возможных причин отсутствия звука после установки состоит в том, что PulseAudio обнаруживает неправильное устройство вывода как значение по умолчанию. Установите {{Pkg|pavucontrol}} и проверьте, существует ли какой-нибудь вывод на панели pavucontrol, например, при проигрывании файла ''.wav''.}}

=== Нет звука, в то время как Master включен ===

В настройках с несколькими выходами (например, 'Наушники' и 'Динамики') использование обычного amixer для выключения канала Master может спровоцировать PulseAudio выключить звук и у активного выхода тоже. Но при включении звука совсем не обязательно, что включение канала Master включит и активный выход [https://lists.freedesktop.org/archives/pulseaudio-discuss/2015-December/025062.html]. Для того чтобы избежать такой проблемы, у amixer необходимо установить переключатель устройств на 'pulse': 

 $ amixer -D pulse sset Master toggle

Это приведет к тому, что amixer будет отправлять запрос на включение/выключение звука к PulseAudio, вместо того, чтобы осуществлять это самостоятельно. Благодаря этому PulseAudio будет корректно включать звук канала Master и иных устройств вывода.

=== Приложение с отключенным звуком ===

Если у определенного приложения отключен звук, или он тихий, в то время как все остальные приложения в порядке. Это может произойти из-за индивидуальной настройки {{ic|sink-input}}. Запустите воспроизведение звука с помощью данного приложения и выполните команду:

 $ pacmd list-sink-inputs

Найдите и запишите {{ic|index}} соответствия {{ic|sink input}}.{{ic|properties:}} {{ic|application.name}} и {{ic|application.process.binary}}, среди прочего, должны помочь здесь. Убедитесь, что установлены правильные настройки, в особенности значения {{ic|muted}} и {{ic|volume}}.
Если у устройства вывода отключен звук, его можно включить:

 $ pacmd set-sink-input-mute <index> false

Если нужна корректировка громкости, она может быть установлена на 100%:

 $ pacmd set-sink-input-volume <index> 0x10000

{{Note (Русский)|Если {{ic|pacmd}} выдаёт {{ic|0 sink input(s)}}, перепроверьте, что приложение воспроизводит звук. Если звук всё ещё отсутствует, проверьте, что другие приложения показываются как устройство вывода.}}

=== Настройка громкости не работает должным образом ===

Проверьте:
{{ic|/usr/share/pulseaudio/alsa-mixer/paths/analog-output.conf.common}}

Если при использовании {{ic|alsamixer}} или {{ic|amixer}} не происходит изменение уровня громкости, это может быть связано с увеличением числа инкрементов PulseAudio (65537, чтобы быть точным). Попытайтесь использовать большие значения при изменении громкости (например, {{ic|amixer set Master 655+}}).

=== Громкость приложений меняется, когда регулируется Общая громкость ===

Это вызвано тем, что PulseAudio использует "плоскую регулировку громкости" (flat-volumes) по умолчанию, вместо относительной регулировки громкости, по сравнению с абсолютной общей регулировкой громкостью. Если это поведение вызывает неудобства, относительная громкость может быть включена путем отключения плоской громкости в файле настроек демона PulseAudio:

{{hc|/etc/pulse/daemon.conf or ~/.config/pulse/daemon.conf|<nowiki>
flat-volumes = no
</nowiki>}}

и затем перезапустите PulseAudio выполнив:

 $ pulseaudio -k
 $ pulseaudio --start

=== Звук становится каждый раз громче, как только запускается новое приложение ===

По умолчанию, кажется, как будто изменение громкости в приложении меняет общую громкость системы, а не только соответствующего приложения. Следовательно, настройки громкости приложения при запуске заставляют системную громкость "прыгать". 

Исправьте это путем отключения "плоской громкости", как продемонстрировано в предыдущем разделе. Когда Pulse перезагрузится через несколько секунд, приложения не будут иметь возможность изменять системную громкость, а вновь будут использовать только свои настройки.

{{Note (Русский)|Ранее установленный и удаленный pulseaudio-equalizer может оставить  настройки в {{ic|~/.config/pulse/default.pa}} или {{ic|~/.pulse/default.pa}}, которые также могут послужить причиной этой проблемы. Закомментируйте эти настройки, при необходимости.}}

=== На звуковой карте M-Audio Audiophile 2 496 звук только Mono ===

Добавьте следующее:

{{hc|/etc/pulseaudio/default.pa|<nowiki>
load-module module-alsa-sink sink_name=delta_out device=hw:M2496 format=s24le channels=10 channel_map=left,right,aux0,aux1,aux2,aux3,aux4,aux5,aux6,aux7
load-module module-alsa-source source_name=delta_in device=hw:M2496 format=s24le channels=12 channel_map=left,right,aux0,aux1,aux2,aux3,aux4,aux5,aux6,aux7,aux8,aux9
set-default-sink delta_out
set-default-source delta_in
</nowiki>}}

=== Нет звука ниже определённого уровня ===

Известная проблема  (не исправление): https://bugs.launchpad.net/ubuntu/+source/pulseaudio/+bug/223133

Если звук не играет, когда громкость PulseAudio регулируется ниже определенного уровня, попробуйте установить {{ic|1=ignore_dB=1}} в {{ic|/etc/pulse/default.pa}}:
{{hc|/etc/pulse/default.pa|<nowiki>
load-module module-udev-detect ignore_dB=1
</nowiki>}}

Однако следует помнить, что это может привести к ошибке предотвращения PulseAudio чтобы включить колонки, когда наушники или другие аудио устройства выключены.

=== Тихая громкость внутреннего микрофона ===

Если у вас низкая громкость звука, на внутреннем микрофоне ноутбука, попытайтесь установить:
{{hc|/etc/pulse/default.pa|<nowiki>
set-source-volume 1 300000
</nowiki>}}

=== Клиенты изменяют основной выход звука (т. е. переход громкости к 100% после запущенного приложения) ===

Если изменение громкости в конкретных приложениях или просто запуск приложения изменяет громкость воспроизведения, это происходит скорее всего из-за режима "плоская громкость" в PulseAudio. Перед отключением, пользователи KDE должны попытаться снизить громкость их системы уведомлений в ''System Settings -> Application and System Notifications -> Manage Notifications'' ('' Системные настройки -> приложения и уведомлений системы -> Управление Уведомлениями '' на вкладке '' Настройки воспроизведения''), на что-то разумное. Тут не поможет изменение ''звуков событий'', громкости в KMix или другом приложении громкости микшера. Это должно заставить режим "плоской громкости" работать как задумано, если он не работает, некоторые другие приложения, скорее всего, запрашивают громкость 100%, когда что-то воспроизводят. Если все остальное не помогает, вы можете попробовать отключить "плоскую громкость":

{{hc|/etc/pulse/daemon.conf|<nowiki>
flat-volumes = no
</nowiki>}}

Затем перезапустите демон PulseAudio:

 # pulseaudio -k
 # pulseaudio --start

=== Нет звука после возобновления из спящего режима ===

Если звук обычно работает, но не работает после спящего режима, попытайтесь "перезагрузить" PulseAudio путем выполнения:
 $ /usr/bin/pasuspender /bin/true

Это лучше, чем  убить, и перезапустить его ({{ic|pulseaudio -k}} сопровождаемый {{ic|pulseaudio --start}}), потому что это уже не повредит запущенные приложения.

Если вышеупомянутое действие решает Вашу проблему, Вы можете автоматизировать это путем создания файла службы systemd.

1. Создайте шаблонный файл службы в {{ic|/etc/systemd/system/resume-fix-pulseaudio@.service}}:

 [Unit]
 Description=Fix PulseAudio after resume from suspend
 After=suspend.target
 
 [Service]
 User=%I
 Type=oneshot
 Environment="XDG_RUNTIME_DIR=/run/user/%U"
 ExecStart=/usr/bin/pasuspender /bin/true
 
 [Install]
 WantedBy=suspend.target
2. Включите его для своей учетной записи пользователя

 # systemctl enable resume-fix-pulseaudio@Здесь_ваше_имя_пользователя.service

3. Перезагрузите systemd

 # systemctl --system daemon-reload

=== Каналы ALSA отключены, когда наушники подсоединены/отсоединены неправильно ===

Когда вы отключаете наушники или подключаете их, звук остается отключенным в alsamixer на неправильном канале, из-за его установки на 0%, вы сможете исправить это, открыв {{ic|/etc/pulse/default.pa}} и закомментировав строку: 

 load-module module-switch-on-port-available

== Микрофон ==

=== PulseAudio не обнаруживает микрофон ===

Определите номер карты и номер устройства Вашего микрофона:

  $ arecord -l
  **** List of CAPTURE Hardware Devices ****
  card 0: PCH [HDA Intel PCH], device 0: ALC269VC Analog [ALC269VC Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

В нотации hw:CARD,DEVICE, Вы определили вышеупомянутое устройство как {{ic|hw:0,0}}.

Затем отредактируйте {{ic|/etc/pulse/default.pa}} и вставьте строку {{ic|load-module}}, определяющую Ваше устройство следующим образом:

   load-module module-alsa-source device=hw:0,0
   # the line above should be somewhere before the line below
  .ifexists module-udev-detect.so

Наконец, перезапустите pulseaudio для применения новых настроек:

   $ pulseaudio -k ; pulseaudio -D

Если все работает правильно, то Вы должны увидеть, что микрофон обнаруживается при выполнении {{ic|pavucontrol}} (на вкладке {{ic|Input Devices}} ).

=== PulseAudio использует неправильный микрофон ===

Если PulseAudio использует неправильный микрофон, и изменение Устройства ввода данных с Pavucontrol не помогло, обратитесь к alsamixer. Случается, что Pavucontrol не всегда устанавливает входной источник правильно.

 $ alsamixer

Нажмите {{ic|F6}} и выберите свою звуковую карту, например, HDA Intel. Теперь нажмите {{ic|F5}} для отображения всех элементов. Попытайтесь найти элемент: {{ic|Input Source}}. С помощью клавиш Вверх / Вниз вы можете изменить источник входного сигнала.

Проверьте, правильный ли микрофон используется для записи теперь.

=== Микрофон работает, но вместо речи, слышен только шум === 

Это касается ноутбуков Lenovo 320 Touch-15IKB (Type 80XN) Laptop (ideapad)
Проблема решается так. Нужно зайти в регулятор громкости pulseaudio. Если регуляторы громкости каналов объединены, нажать кнопку "связать громкости каналов" Убрать до 0 громкость одного из каналов (скрее всего правого) микрофона.  

=== Нет микрофона на ThinkPad T400/T500/T420 ===

Выполните:

 alsamixer -c 0

Включите звук и увеличьте громкость "Internal Mic" (внутреннего микрофона) до максимума.

После того, как вы увидите устройство с помощью: 

 arecord -l

Вам, возможно, все еще нужно будет скорректировать настройки. Микрофон и аудиоразъем являются дуплексными. Установите настройки внутреннего аудио pavucontrol в ''Analog Stereo Duplex'' (''Аналоговому Дуплексу Стерео'').

=== Нет микрофона на Acer Aspire One ===

Установите pavucontrol, выключите каналы микрофона и установите его левый канал на 0.
Ссылка: http://getsatisfaction.com/jolicloud/topics/deaf_internal_mic_on_acer_aspire_one#reply_2108048

=== Статический шум в записи микрофона ===

Если мы получаем статический шум в записях Skype, gnome-sound-recorder, arecord, и т.д., то в этом случае частота дискретизации звуковой карты является неправильной. Именно поэтому в записях микрофона Linux существует статический шум. Для того чтобы это исправить, мы должны установить уровень выборки (sampling rate) в {{ic|/etc/pulse/daemon.conf}} для звукового оборудования.
В дополнение к руководству, приведенному ниже, начиная с [https://www.freedesktop.org/wiki/Software/PulseAudio/Notes/11.0/ PulseAudio 11] стало возможным установить параметр {{ic|1=avoid-resampling = yes}} в {{ic|daemon.conf}} для использования частоты дискретизации приложения без ресемплирования.

==== Определение звуковых карт в системе (1/5) ====

Для этого потребуется пакет {{Pkg|alsa-utils}} и связанные с ним:
{{hc|$ arecord --list-devices|

**** List of CAPTURE Hardware Devices ****
card 0: Intel [HDA Intel], device 0: ALC888 Analog [ALC888 Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 0: Intel [HDA Intel], device 2: ALC888 Analog [ALC888 Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
}}

{{ic|hw:0,0}} является звуковой картой.

==== Определить частоту дискретизации звуковой карты (2/5) ====

Нашей задачей будет поиск максимальной частоты дискретизации, поддерживаемой звуковой картой {{ic|hw:0,0}}, используя метод ''проб и ошибок'', начиная с самого маленького значения. Когда будет достигнут наивысший предел, мы получим предупреждающее сообщение:

{{hc|1=arecord -f dat -r 60000 -D hw:0,0 -d 5 test.wav|2=
"Recording WAVE 'test.wav' : Signed 16 bit Little Endian, Rate 60000 Hz, Stereo
Warning: rate is not accurate (requested = 60000Hz, '''got = 44100Hz''')
please, try the plug plugin
}}

обратите внимание на {{ic|1=got = 44100Hz}}. Это максимальная частота дискретизации нашей карты.

==== Установка частоты дескритизации в настройках PulseAudio (3/5) ====

Уровень дескритизации, по умолчанию, в PulseAudio:
{{hc|1=$ grep "default-sample-rate" /etc/pulse/daemon.conf|2=
; default-sample-rate = 48000
}}

{{ic|48000}} отключен, и должен быть изменен на {{ic|44100}}:
 # sed 's/; default-sample-rate = 48000/default-sample-rate = 44100/g' -i /etc/pulse/daemon.conf

==== Перезапустите PulseAudio для применения новых настроек (4/5) ====

 $ pulseaudio -k
 $ pulseaudio --start

==== Наконец, проверьте запись и её воспроизведение (5/5) ====

Давайте запишем речь с помощью микрофона в течение, например, 10 секунд. Удостоверьтесь, что микрофон не отключен.

 $ arecord -f cd -d 10 test-mic.wav

После 10 секунд, давайте проиграем запись:

 $ aplay test-mic.wav

Теперь, надеюсь, больше нет никакого статического шума на записи с микрофона.

==== Иная возможная причина ====

Другой причиной рассматриваемой проблемы может быть то, что ваш микрофон имеет два канала, но только один из них может выдавать верный сигнал. Некоторую информацию об этом можно найти [https://github.com/MaartenBaert/ssr/issues/323#issuecomment-268230548 здесь]. Решением будет перенастройка стерео входа в режим моно:

1. Найдите название источника входного сигнала, используя следующую команду (например, оно может быть таким {{ic|alsa_input.pci-0000_00_1f.3.analog-stereo}})

 pacmd list-sources | grep 'name:.*input'

2. Отредактируйте {{ic|/etc/pulse/default.pa}} и добавьте следующие строки, где INPUT_NAME - это имя источника входного сигнала из предыдущего пункта:

 load-module module-remap-source source_name=record_mono master=INPUT_NAME master_channel_map=front-left channel_map=mono
 set-default-source record_mono

3. Перезапустите PulseAudio:

 pulseaudio -k
 pulseaudio --start

Надеемся, что {{ic|arecord}} теперь работает. Вам все еще может потребоваться изменить параметр {{ic|RecordStream from}} на {{ic|Remapped Built-in Audio Analog Stereo}} для конкретного приложения во вкладке {{ic|Recording}} приложения {{ic|pavucontrol}}.

==== Если используется USB микрофон ====

Попробуйте подключить его к другому разъёму (например, разъёму сзади, а не спереди).

=== Нет микрофона в Steam или Skype с enable-remixing = no ===

Когда Вы установите {{ic|1=enable-remixing = no}} в {{ic |/etc/pulse/daemon.conf}}, Вы можете обнаружить, что Ваш микрофон перестал работать в определенных приложениях, таких как Skype или Steam. Это происходит потому, что эти приложения используют микрофон только как моно, потому что отключен remixing. Pulseaudio больше не будет делать «remixing» Вашего стереомикрофона в моно.

Чтобы исправить это, вы должны указать PulseAudio, делать это за вас: 

1. Найти имя источника 

 # pacmd list-sources

Пример вывода отредактирован для краткости, имя которое вам нужно, выделено жирным: 

    index: 2
        name: <'''alsa_input.pci-0000_00_14.2.analog-stereo'''>
        driver: <module-alsa-card.c>
        flags: HARDWARE HW_MUTE_CTRL HW_VOLUME_CTRL DECIBEL_VOLUME LATENCY DYNAMIC_LATENCY

2. Добавить правило переназначения в {{ic|/etc/pulse/default.pa}}, используйте имя, которое Вы нашли предыдущей командой, здесь мы будем использовать '''alsa_input.pci-0000_00_14.2.analog-stereo''' в качестве примера:

{{hc|/etc/pulse/default.pa|<nowiki>
### Remap microphone to mono
load-module module-remap-source master=alsa_input.pci-0000_00_14.2.analog-stereo master_channel_map=front-left,front-right channels=2 channel_map=mono,mono
</nowiki>}}

3. Перезапустите Pulseaudio

 # pulseaudio -k

{{Note (Русский)|Pulseaudio может не запуститься, если Вы не вышли из программы, использовавшей микрофон (например, если Вы протестировали его в Steam, прежде, чем изменить файл), тогда Вы должны выйти из приложения, и вручную запустить Pulseaudio}}

 # pulseaudio --start

=== Искажение микрофона из-за автоматической регулировки ===

Если громкость микрофона повышается автоматически и вызывает искажение звука, вы можете это исправить путем отключения усиления микрофона:

В {{ic|/usr/share/pulseaudio/alsa-mixer/paths/analog-input-internal-mic.conf}} и {{ic|/usr/share/pulseaudio/alsa-mixer/paths/analog-input-mic.conf}},

* Под {{ic|[Element Internal Mic Boost]}} установите {{ic|volume}} в {{ic|zero (ноль)}}.
* Под {{ic|[Element Int Mic Boost]}} установите {{ic|volume}} в {{ic|zero (ноль)}}.
* Под {{ic|[Element Mic Boost]}} установите {{ic|volume}} в {{ic|zero (ноль)}}.
Либо отредактировать аналогичные файлы в папке по адресу:
{{ic|/usr/share/alsa-card-profile/mixer/paths/}}

Затем перезапустите PulseAudio:

 # pulseaudio -k

== Качество звука ==

=== Глюки, пропуски или потрескивания ===

Более новая реализация звукового сервера PulseAudio использует звуковой планировщик на основе таймера, вместо традиционного подхода управления прерываниями.

Основанное на таймере планирование может представлять проблемы в некоторых драйверах ALSA. С другой стороны, другие драйверы могли бы глючить без него, проверьте и посмотрите что работает на вашей системе.

Для выключения основанного на таймере планирования добавьте {{ic|1=tsched=0}} в {{ic|/etc/pulse/default.pa}}:
{{hc|/etc/pulse/default.pa|2=
load-module module-udev-detect tsched=0
}}

Затем перезапустите сервер PulseAudio:

 pulseaudio -k
 pulseaudio --start

Наоборот, для включения основанного на таймере планирования, если он уже не включен по умолчанию.

Если Вы используете Intel [[Wikipedia:IOMMU|IOMMU]] и испытываете глюки и/или пропуски, добавьте {{ic|1=intel_iommu=igfx_off}} к Вашей командной строке ядра.

Некоторым звуковым картам Intel использующим модуль {{ic|snd-hda-intel}} нужны опции 
{{ic|1=vid=8086 pid=8ca0 snoop=0}}. Для постоянной их установки создайте/измените следующий файл, включая строку ниже.
{{hc|/etc/modprobe.d/sound.conf|2=
options snd-hda-intel vid=8086 pid=8ca0 snoop=0
}}

Сообщите о любых таких картах [https://www.freedesktop.org/wiki/Software/PulseAudio/Backends/ALSA/BrokenDrivers/ PulseAudio Broken Sound Driver page]

=== Статический шум при использовании наушников ===

Если вы столкнулись со статическим шумом в разъеме наушников, одной из причин этому может быть петлевое смешивание (loopback mixing) ALSA. В дополнение к настройке {{ic|1=tsched=0}} как описано выше, может помочь отключение петлевого смешивания (loopback mixing). Это легко можно сделать с помощью alsamixer, частью пакета {{Pkg|alsa-utils}}. Это не должно оказать негативного влияния на воспроизведение или запись звука, кроме случаев, когда петлевое смешивание вам обязательно нужно.

=== Определение номера фрагмента по умолчанию и размера буфера в PulseAudio ===

==== Отключение планирования, основанного на таймере (0/4) ====

По умолчанию PulseAudio использует планирование, основанное на таймере. В этом режиме фрагменты совсем не используются, и игнорируются параметры default-fragments и default-fragment-size-msec parameters.
Чтобы отключить планирование, основанное на таймере, добавьте {{ic|1=tsched=0}} в {{ic|/etc/pulse/default.pa}}:
{{hc|/etc/pulse/default.pa|2=
load-module module-udev-detect tsched=0
}}

==== Поиск параметров вашего аудиоустройства (1/4) ====

Чтобы выяснить настройки буфера звуковой карты, используйте следующую команду, пока не найдете правильную запись выходного канала:

{{hc|$ pactl list sinks|<nowiki>
Sink #1
	State: RUNNING
	Name: alsa_output.pci-0000_00_1b.0.analog-stereo
	Description: Built-in Audio Analog Stereo
	Driver: module-alsa-card.c
	Sample Specification: s16le 2ch 44100Hz
	Channel Map: front-left,front-right
	Owner Module: 7
	Mute: no
	Volume: front-left: 42600 /  65% / -11.22 dB,   front-right: 42600 /  65% / -11.22 dB
	        balance 0.00
	Base Volume: 65536 / 100% / 0.00 dB
	Monitor Source: alsa_output.pci-0000_00_1b.0.analog-stereo.monitor
	Latency: 70662 usec, configured 85000 usec
	Flags: HARDWARE HW_MUTE_CTRL HW_VOLUME_CTRL DECIBEL_VOLUME LATENCY 
	Properties:
		alsa.resolution_bits = "16"
		device.api = "alsa"
		device.class = "sound"
		alsa.class = "generic"
		alsa.subclass = "generic-mix"
		alsa.name = "ALC283 Analog"
		alsa.id = "ALC283 Analog"
		alsa.subdevice = "0"
		alsa.subdevice_name = "subdevice #0"
		alsa.device = "0"
		alsa.card = "1"
		alsa.card_name = "HDA Intel PCH"
		alsa.long_card_name = "HDA Intel PCH at 0xe111c000 irq 43"
		alsa.driver_name = "snd_hda_intel"
		device.bus_path = "pci-0000:00:1b.0"
		sysfs.path = "/devices/pci0000:00/0000:00:1b.0/sound/card1"
		device.bus = "pci"
		device.vendor.id = "8086"
		device.vendor.name = "Intel Corporation"
		device.product.id = "9ca0"
		device.product.name = "Wildcat Point-LP High Definition Audio Controller"
		device.form_factor = "internal"
		device.string = "front:1"
		device.buffering.buffer_size = "352800"
		device.buffering.fragment_size = "176400"
		device.access_mode = "mmap+timer"
		device.profile.name = "analog-stereo"
		device.profile.description = "Analog Stereo"
		device.description = "Built-in Audio Analog Stereo"
		alsa.mixer_name = "Realtek ALC283"
		alsa.components = "HDA:10ec0283,10ec0283,00100003"
		module-udev-detect.discovered = "1"
		device.icon_name = "audio-card-pci"
	Ports:
		analog-output-speaker: Speakers (priority: 10000, not available)
		analog-output-headphones: Headphones (priority: 9000, available)
	Active Port: analog-output-headphones
	Formats:
		pcm
...
</nowiki>}}

Обратите внимание на то, что значения {{ic|buffer_size}} и {{ic|fragment_size}} релевантны соответствующей звуковой карте.

==== Вычисление размера вашего фрагмента в миллисекундах и количества фрагментов (2/4) ====

Частота дискретизации и битовая глубина PulseAudio по умолчанию установлены на {{ic|44100Hz}} @ {{ic|16 bits}}.

При такой конфигурации нам нужен битрейт {{ic|44100}}*{{ic|16}} = {{ic|705600}} бит в секунду. Для стерео - {{ic|1411200 bps}}.

Давайте взглянем на параметры, которые мы нашли в предыдущем шаге:

 device.buffering.buffer_size = "352800" => 352800/1411200 = 0.25 s = 250 ms
 device.buffering.fragment_size = "176400" => 176400/1411200 = 0.125 s = 125 ms

==== Редактирование конфигурационного файла PulseAudio (3/4) ====

{{hc|/etc/pulse/daemon.conf|<nowiki>
; default-fragments = X
; default-fragment-size-msec = Y
</nowiki>}}

В предыдущем шаге мы рассчитали размер фрагмента.
Узнать количество фрагментов также просто: buffer_size/fragment_size. Ответ в нашем случае будет равен ({{ic|250/125}}) {{ic|2}}:

{{hc|/etc/pulse/daemon.conf|2=
; default-fragments = '''2'''
; default-fragment-size-msec = '''125'''
}}

==== Перезапуск демона PulseAudio (4/4) ====

 $ pulseaudio -k
 $ pulseaudio --start

Для получения дополнительной информации смотрите: [https://forums.linuxmint.com/viewtopic.php?f=42&t=44862 тему на форуме Linux Mint]

=== Прерывистый звук с аналогового объемного звучания ===

Канал низкочастотных эфектов (НЭ) не ремикширован по умолчанию. Чтобы включить его, нужно изменить следующее в {{ic|/etc/pulse/daemon.conf}}:

{{hc|/etc/pulse/daemon.conf|<nowiki>
enable-lfe-remixing = yes
</nowiki>}}

=== Тормозит звук ===

Эта проблема возникает из-за неправильного размера буфера. Сначала убедитесь, что значение по умолчанию для переменных {{ic|default-fragments}} и {{ic|default-fragment-size-msec}} не изменено в файле {{ic|/etc/pulse/daemon.conf}}. Если это не помогло, попробуйте установить этим переменным следующие значения:

{{hc|/etc/pulse/daemon.conf|2=
default-fragments = 5
default-fragment-size-msec = 2
}}

=== Прерывистый/искажённый звук ===

Искажённый звук может быть вызван неправильно настроенной частотой дискретизации. Попробуйте следующие настройки:

{{hc|/etc/pulse/daemon.conf|2=
avoid-resampling = yes #(Необходимо для [https://www.freedesktop.org/wiki/Software/PulseAudio/Notes/11.0/ PA11] или новее)
default-sample-rate = 48000
}}
и перезапустите сервер PulseAudio.

Если искажённый звук возникает в приложениях, использующих [[Wikipedia:ru:OpenAL|OpenAL]], поменяйте частоту дискретизации в {{ic|/etc/openal/alsoft.conf}}:
{{hc|/etc/openal/alsoft.conf|2=
frequency = 48000
}}

Установка PCM volume выше 0 dB может вызвать [[Wikipedia:ru:Клиппинг_(аудио)|клиппинг]]. Запуск {{ic|alsamixer}} позволит вам обнаружить и исправить проблему. Обратите внимание, что ALSA может [https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/PulseAudioStoleMyVolumes некорректно экспортировать] информацию о dB в PulseAudio. Попробуйте следующее:

{{hc|/etc/pulse/default.pa|2=
load-module module-udev-detect ignore_dB=1
}}

и перезапустите сервер PulseAudio. Смотрите также [[#Нет звука ниже определённого уровня]].

== Аппаратные средства и карты ==

=== Спустя некоторое время, при выключенном мониторе отсутствует звук на выходе HDMI ===

Монитор подключается через HDMI/DisplayPort, а аудиоразъем подключен к разъему для наушников монитора, но PulseAudio настаивает на том, что он отключен:

{{hc|pactl list sinks|
...
hdmi-output-0: HDMI / DisplayPort (priority: 5900, not available)
...
}}

Это приводит к отсутствию звука из выхода HDMI. Чтобы это обойти, переключитесь на другой VT и обратно. Если это не сработает, попробуйте: выключить монитор, переключиться на другой VT, включить монитор, а затем обратно. Эта проблема была обнаружена пользователями ATI/Nvidia/Intel.

Решить проблему можно иначе: отключить модуль switch-on-port-available, закомментировав его в {{ic|/etc/pulse/default.pa}}
[https://bugs.freedesktop.org/show_bug.cgi?id=93946#c36]:

{{hc|/etc/pulse/default.pa|
...
### Следует разместить после module-*-restore но до module-*-detect
#load-module module-switch-on-port-available
...
}}

=== Отсутствие звука на выходе HDMI при использовании удаленного сервера ===

Возможно Вы захотите использовать HDMI аудио через Ваш a/v ресивер, но без использования дисплея. Для работы HDMI требуется видеосигнал, который мы получаем от виртуального терминала.  

По умолчанию, сигнал отключается через 600 секунд, а вместе с ним пропадает и звук.

Чтобы запретить выключать экран, добавьте {{ic|consoleblank&#61;0}} в командную строку ядра.

=== Нет карты ===

Если PulseAudio запускается, а выполнение {{ic|pacmd list}} говорит что нет карт, убедитесь что они не используются устройствами ALSA:

 $ fuser -v /dev/snd/*
 $ fuser -v /dev/dsp

Убедитесь, что все приложения, использующие файлы pcm или dsp закрыты перед перезапуском PulseAudio.

=== Запуск приложения прерывает звук другого приложения ===

Если у вас есть проблемы с некоторыми приложениями (например Teamspeak, Mumble) прерывающих звук уже запущенных приложений (например Deadbeaf), вы можете решить эту проблему закомментировав строку {{ic|load-module module-role-cork}} в {{ic|/etc/pulse/default.pa}} как показано ниже:

{{hc|/etc/pulse/default.pa|
### Cork music/video streams when a phone stream is active
# load-module module-role-cork
}}

Затем перезагрузите PulseAudio, используя обычную учетную запись пользователя
 
 pulseaudio -k
 pulseaudio --start

=== Единственное указанное устройство является "фиктивным выходом" или вновь подключенные карты не определяются ===

Если единственное устройство воспроизведения является "фиктивным выходом", PulseAudio не сможет получить доступ к Вашим звуковым устройствам. Вероятно это связано с настройком прав {{ic|logind}}. Для более детальной информации перейдите по ссылке [[General troubleshooting#Session permissions]].

Приложение также может быть просто не настроено для работы с PulseAudio. Например, подобная проблема наблюдается в [[FluidSynth#Conflicting with PulseAudio|FluidSynth]]. Чтобы увидеть, какое приложение пытается получить прямой доступ к звуковой карте  через ALSA, выполните следующую команду:

 # fuser -v /dev/snd/*

Попробуйте закрыть эти приложения. PulseAudio, если запущено, должно восстановить контроль над этими приложениями, и все остальные приложения, относящиеся к PulseAudio, снова должны начать работать.

=== Не возможно выбрать устройства HDMI 5/7.1 ===

Если вы не можете выбрать каналы выхода 5/7.1 для работающего устройства HDMI, вам может помочь выключение "stream device reading" в {{ic|/etc/pulse/default.pa}}. 

Смотрите [[#Резервное устройство не определяется]].

=== Не удалось создать устройство входа: устройство приостановлено ===

Если у Вас нет вывода звука и Вы получаете десятки ошибок связанных с зависанием устройства в вашем журнале {{ic|journalctl -b}}, сделайте резервную копию, а затем удалите в своём домашнем каталоге папки Pulse:

 $ rm -r ~/.pulse ~/.pulse-cookie ~/.config/pulse

=== Одновременный вывод на несколько звуковых карт / устройств ===

Одновременный вывод на два различных устройства может быть очень полезным. Например, отправка звука на Ваш A/V ресивер через HDMI выход видеокарты, и параллельная отправка того же самого звука посредством аналогового выхода встроенного аудио Вашей материнской платы. Теперь это менее хлопотно, чем раньше (в этом примере, мы используем рабочий стол GNOME).

Используя {{Pkg|paprefs}}, просто выберите "Добавить устройство виртуального выхода для одновременного вывода на всех локальных звуковых картах (Add virtual output device for simultaneous output on all local sound cards)" из вкладки "Одновременный вывод (Simultaneous Output)" . Затем в "Настройках Звука" GNOME, выберите одновременный вывод, который вы только что создали.

Если это не сработает, попробуйте добавить следующее в {{ic|~/.asoundrc}}:

 pcm.dsp {
    type plug
    slave.pcm "dmix"
 }

{{Tip (Русский)|Одновременный вывод также может быть настроен вручную с помощью alsamixer. Отключите пункт "автоматическое отключение звука (auto mute)", затем включите другие источники вывода которые хотите услышать и увеличьте их громкость.}}

=== Одновременный вывод на несколько устройств вывода на одной звуковой карте не работает ===

Это будет полезно для пользователей, у которых несколько источников звука, и они хотят воспроизводить их на разных устройствах вывода/выходах. Пример того как это использовать: допустим вы слушаете музыку и общаетесь в голосовом чате, и хотите выводить музыку на колонки (в данном случае цифровой S/PDIF) а голос в наушники (Аналог).

Иногда, но не всегда, PulseAudio автоматически это обнаруживает. Если вы знаете что ваша звуковая карта может выводить звук на Аналоговый выход и S/PDIF одновременно, и у PulseAudio нет этой опции в своих профилях на pavucontrol или veromix, то вам нужно будет создать файл настроек для вашей звуковой карты.

Вам нужно создать более подробный профиль для конкретной звуковой карты.
Это, в основном, делается в два этапа.
* Создать правило Udev для разрешения PulseAudio выбирать ваш файл настроек PulseAudio подготовленный для конкретной звуковой карты
* Создать актуальные настройки

Создать правило PulseAudio udev.

{{Note (Русский)|Этот пример применим только для Asus Xonar Essence STX.
Изучите [[udev (Русский)|udev]] чтобы подобрать верные значения.}}

{{Note (Русский)|Чтобы применился именно Ваш файл настроек, он должен иметь меньшее число, чем исходное правило PulseAudio.}}

{{hc|/usr/lib/udev/rules.d/90-pulseaudio-Xonar-STX.rules|
ACTION&#61;&#61;"change", SUBSYSTEM&#61;&#61;"sound", KERNEL&#61;&#61;"card*", \
ATTRS&#123;subsystem_vendor&#125;&#61;&#61;"0x1043", ATTRS&#123;subsystem_device&#125;&#61;&#61;"0x835c", ENV&#123;PULSE_PROFILE_SET&#125;&#61;"asus-xonar-essence-stx.conf" 
}}

Теперь создайте файл настроек. Если потрудиться, вы можете написать его с нуля и сделать его красивым. Однако можете воспользоватся файлом настроек по умолчанию, переименовать его, а затем добавить в свой профиль то, что будет там работать. Это менее красиво, зато быстро.

Чтобы включить несколько устройств вывода для Asus Xonar Essence STX, нужно только добавить это.

{{Note (Русский)|{{ic|asus-xonar-essence-stx.conf}} также содержит все коды/инструкции из {{ic|default.conf}}.}}

{{hc|/usr/share/pulseaudio/alsa-mixer/profile-sets/asus-xonar-essence-stx.conf|
[Profile analog-stereo+iec958-stereo]
description &#61; Analog Stereo Duplex + Digital Stereo Output
input-mappings &#61; analog-stereo
output-mappings &#61; analog-stereo iec958-stereo
skip-probe &#61; yes
}}

Это будет авто-профилем Asus Xonar Essence STX с профилями по умолчанию и добавит свой собственный профиль, так что вы можете иметь несколько устройств вывода.

Вам нужно создать еще один профиль в файле настроек, если вы хотите получить такую же функциональность с выходом AC3 Digital 5.1.

[https://www.freedesktop.org/wiki/Software/PulseAudio/Backends/ALSA/Profiles/ смотрите статью о профилях PulseAudio]

=== Некоторые профили, такие как SPDIF не задействованы по умолчанию на карте ===

Некоторые профили, такие как IEC-958 (т.е. S/PDIF) могут быть не задействованы на выбранном устройстве по умолчанию. Каждый раз когда система запускается, профиль карты блокируется, и демон PulseAudio не может его выбрать.
Вы должны добавить выбор профиля в ваш файл default.pa. 
Проверьте имя карты и профиль:

 $ pacmd list-cards
Затем отредактируйте файл настроек, чтобы добавить профиль
{{hc|~/.config/pulse/default.pa|
## Замените на ваши имена карты и профиля, которые вы хотите активировать
set-card-profile alsa_card.pci-0000_00_1b.0 output:iec958-stereo+input:analog-stereo
}}

PulseAudio добавит этот профиль, в пул доступных профилей.

== Bluetooth ==

=== Отключение поддержки Bluetooth ===

Если вы не используете Bluetooth, вы можете обнаружить следующую ошибку в журнале:

 bluez5-util.c: GetManagedObjects() failed: org.freedesktop.DBus.Error.ServiceUnknown: The name org.bluez was not provided by any .service files

Чтобы отключить поддержку Bluetooth в PulseAudio, убедитесь, что следующие строчки закомментированы в используемом файле конфигурации ({{ic|~/.config/pulse/default.pa}} или {{ic|/etc/pulse/default.pa}}):

{{hc|~/.config/pulse/default.pa|
### Automatically load driver modules for Bluetooth hardware
#.ifexists module-bluetooth-policy.so
#load-module module-bluetooth-policy
#.endif

#.ifexists module-bluetooth-discover.so
#load-module module-bluetooth-discover
#.endif
}}

=== Проблемы воспроизведения гарнитуры Bluetooth ===

Некоторые пользователи [https://bbs.archlinux.org/viewtopic.php?id=117420 сообщают] о больших задержках или даже отсутствии звука, когда по Bluetooth-соединению не передаются никакие данные. Это вызвано модулем {{ic|module-suspend-on-idle}}, который автоматически приостанавливает устройства ввода/вывода при простое. Так как это может вызвать проблемы с гарнитурой, можно отключить соответствующий модуль.

Для отключения загрузки модуля {{ic|module-suspend-on-idle}} закомментируйте следующую строчку в используемом файле конфигурации ({{ic|~/.config/pulse/default.pa}} или {{ic|/etc/pulse/default.pa}}):

{{hc|~/.config/pulse/default.pa|
### Automatically suspend sinks/sources that become idle for too long
#load-module module-suspend-on-idle
}}

И перезагрузите PulseAudio для применения изменений.

=== Автоматическое переключение на Bluetooth или USB-гарнитуру ===

Добавьте следующие строчки в файл конфигурации:
{{hc|/etc/pulse/default.pa|
# automatically switch to newly-connected devices
load-module module-switch-on-connect
}}

Начиная с [https://www.freedesktop.org/wiki/Software/PulseAudio/Notes/11.0/ PulseAudio 11] USB и bluetooth устройства по умолчанию имеют больший приоритет по сравнению с внутренней звуковой картой. Но, как указано по ссылке выше, Вам все еще необходим модуль module-switch-on-connect для перемещения существующих потоков на новое устройство вывода.

=== Устройство сопряжено, но не проигрывает звук ===

[[Bluetooth headset#A2DP not working with PulseAudio|Смотрите раздел в статье Bluetooth]]

Начиная с PulseAudio 2.99 и bluez 4.101, вы должны '''избегать''' использования интерфейса Socket. НЕ используйте:

{{hc|/etc/bluetooth/audio.conf|<nowiki>
[General]
Enable=Socket
</nowiki>}}

Если вы имеете проблемы с A2DP и PA 2.99, убедитесь, что у вас установлена библиотека {{Pkg|sbc}}.

== Приложения ==

=== Содержащие Flash ===

Поскольку Adobe Flash напрямую не поддерживает PulseAudio, рекомендуется [[PulseAudio (Русский)#ALSA|настроить ALSA использовать виртуальную звуковую карту PulseAudio]].

Если звук Flash заикается, можете попробовать использовать Flash через ALSA напрямую. Подробно смотрите [[PulseAudio (Русский)#ALSA/dmix без захвата аппаратного устройства|ALSA/dmix без захвата аппаратного устройства]].

=== Audacity ===

При запуске Audacity вы можете обнаружить, что ваши наушники не работают. Это может быть потому, что Audacity пытается использовать их в качестве записывающего устройства. Чтобы исправить это, откройте Audacity, затем установите его записывающее устройство {{ic|1=pulse:Internal Mic:0}}.

В некоторых случаях, воспроизведение может быть искажено, ускоряться , или зависать, как описано в [https://wiki.audacityteam.org/wiki/Linux_Issues#ALSA_and_other_sound_systems Audacity Wiki's Linux Issues page].

Вам может помочь следующее решение: запустите Audacity с опцией:

 $ env PULSE_LATENCY_MSEC=30 audacity

Если указанное выше решение, не решает эту проблему, то можно временно отключить pulseaudio, во время работы Audacity при помощи команды {{ic|pasuspender}}:

 $ pasuspender -- audacity

Затем не забудьте выбрать соответствующие устройства ввода и вывода ALSA в Audacity.

Смотрите также [[#Определение номера фрагмента по умолчанию и размера буфера в PulseAudio]].

== Другие проблемы ==

=== Плохой файл настроек ===

Если после запуска PulseAudio в системе нету звука, возможно необходимо удалить содержимое папки {{ic|~/.config/pulse}} и/или {{ic|~/.pulse}}. PulseAudio автоматически создаст новые файлы настроек при своём следующем запуске.

=== Невозможно обновить настройки звукового устройства в pavucontrol ===

{{Pkg|pavucontrol}} представляет собой удобную утилиту с графическим интерфейсом для настройки PulseAudio. На вкладке 'Настройки', вы можете выбрать различные профили для каждого из ваших звуковых устройств, например: аналоговое стерео, цифровой выход (IEC958), HDMI 5.1 Surround и т.д.

Тем не менее, вы можете столкнуться со случаем, когда выбор другого профиля для карты приведёт к сбою демона Pulse и "зависнет" автоматическое повторное включение без сохранения нового выбора. Если это происходит, используйте другой полезный инструмент с графическим интерфейсом, {{Pkg|paprefs}}, чтобы проверить настройку на вкладке "Одновременный вывод" для виртуального "одновременного устройства". Если этот параметр активен (флажок установлен), то это будет мешать вам измененить профиль любой карты в pavucontrol. Снимите флажок этого параметра, а затем настройте свой профиль в pavucontrol до повторного включения одновременного вывода в paprefs.

=== Не удалось создать устройство вывода: устройство вывода приостановлено ===

Если у вас нету звука, и вы получаете десятки ошибок связанных с приостановкой устройства вывода в вашем журнале {{ic|journalctl -b}}, сначала создайте резервную копию, а потом удалите папки pulse в вашем домашнем каталоге:

 $ rm -r ~/.pulse ~/.pulse-cookie ~/.config/pulse

=== Pulse переписывает настройки ALSA ===

PulseAudio обычно переписывает настройки ALSA — например устанавливает alsamixer при загрузке, даже когда демон ALSA загружен. Так как нет иного способа избежать такого поведения, решение заключается в восстановлении настроек ALSA после запуска PulseAudio. Добавьте следующую команду в {{ic|.xinitrc}} или {{ic|.bash_profile}} или другой файл [[Autostarting (Русский)|Автоматической загрузки]]:

 restore_alsa() {
  while [ -z "$(pidof pulseaudio)" ]; do
   sleep 0.5
  done
  alsactl -f /var/lib/alsa/asound.state restore 
 }
 restore_alsa &

=== Предотвращение перезагрузки Pulse, после того как процесс был убит (kill) ===

Иногда вам может потребоваться временно отключить Pulse. Для того чтобы сделать это, вы должны запретить повторный запуск Pulse, после того как процесс был убит.

{{hc|~/.config/pulse/client.conf|2=
# Disable autospawning the PulseAudio daemon
autospawn = no
}}

=== Не удаётся запустить Демон ===

Попробуйте сбросить PulseAudio:

 $ rm -rf /tmp/pulse* ~/.pulse* ~/.config/pulse
 $ pulseaudio -k
 $ pulseaudio --start

* Убедитесь, что параметры для устройств вывода настроены правильно.

* Если вы настроили default.pa для загрузки и использования модулей OSS проверьте с помощью {{Pkg|lsof}} что устройство {{ic|/dev/dsp}} не используется другим приложением.

* Установите предпочтительный метод работы передискретизации. Используйте {{ic|pulseaudio --dump-resample-methods}} чтобы увидеть список всех доступных методов ресэмплирования (resample), которые вы можете использовать.

* Чтобы получить подробную информацию о недавно появившихся незаписанных ошибках или просто получить статус демона, используйте команду {{ic|pax11publish -d}} и {{ic|pulseaudio -v}}, где {{ic|v}} опция может быть использована многократно для установления подробности вывода журнала, равное {{ic|1=--log-level[=LEVEL]}} опции где LEVEL от 0 до 4. Смотрите раздел [[#Вывод статуса ошибок PulseAudio утилитами проверки]].

Для более подробной информации смотрите страницу справки {{man|1|pax11publish}} и {{man|1|pulseaudio}}.

==== Вывод статуса ошибок PulseAudio утилитами проверки ====

Если {{ic|pax11publish -d}} показывает ошибку как:

 N: [pulseaudio] main.c: User-configured server at "user", refusing to start/autospawn.

то запустите команду {{ic|pax11publish -r}}, и будет не лишним, если вы выйдите из системы и войдёте снова.

Если команда {{ic|pulseaudio -vvvv}} показывает ошибку:

 E: [pulseaudio] module-udev-detect.c: You apparently ran out of inotify watches, probably because Tracker/Beagle took them all away. I wished people would do their homework first and fix inotify before using it for watching whole directory trees which is something the current inotify is certainly not useful for. Please make sure to drop the Tracker/Beagle guys a line complaining about their broken use of inotify.

Эту проблему можно временно решить с помощью:

 $ echo 100000 > /proc/sys/fs/inotify/max_user_watches

Для постоянного использования сохраните настройки в файл ''99-sysctl.conf'':

{{hc|/etc/sysctl.d/99-sysctl.conf|2=
# Increase inotify max watchs per user
fs.inotify.max_user_watches = 100000}}

{{Warning (Русский)|Это может привести к гораздо большему потреблению памяти ядром.}}

'''Смотрите также''' 

* [http://www.linuxinsight.com/proc_sys_fs_inotify.html proc_sys_fs_inotify]{{Dead link (Русский)|2020|08|04|status=domain name not resolved}} и [https://lwn.net/Articles/604686/ dnotify, inotify]- детальное описание ''inotify/max_user_watches''
* [https://stackoverflow.com/questions/535768/what-is-a-reasonable-amount-of-inotify-watches-with-linux?answertab=votes#tab-top reasonable amount of inotify watches with Linux]
* {{man|7|inotify}} - страница руководства

=== Демон уже запущен ===

В некоторых системах, PulseAudio может быть запущен несколько раз. В таком случае journalctl сообщит:

 [pulseaudio] pid.c: Daemon already running.

Убедитесь в том, что используете только один метод автоматического запуска приложений. {{Pkg|pulseaudio}} содержит следующие файлы:

* {{ic|/etc/X11/xinit/xinitrc.d/pulseaudio}}
* {{ic|/etc/xdg/autostart/pulseaudio.desktop}}
* {{ic|/etc/xdg/autostart/pulseaudio-kde.desktop}}

Также проверьте пользовательские файлы и каталоги автозапуска, такие как [[xinitrc (Русский)|xinitrc]], {{ic|~/.config/autostart/}} и т.п..

=== Сабвуфер перестает работать после окончания каждой песни ===

Известные проблемы: https://bugs.launchpad.net/ubuntu/+source/pulseaudio/+bug/494099

Чтобы это исправить, необходимо включить {{ic|enable-lfe-remixing}} в файле {{ic|/etc/pulse/daemon.conf}}:
{{hc|/etc/pulse/daemon.conf|<nowiki>
enable-lfe-remixing = yes
</nowiki>}}

=== Невозможно выбрать настройку объемного звучания, кроме "Surround 4.0" ===

Если вам не удается установить 5.1-канальный вывод объемного звучания в pavucontrol, поскольку он показывает только "Analog Surround 4.0 Output", откройте микшер ALSA и измените настройку вывода на 6 каналов. Затем перезагрузите PulseAudio и pavucontrol покажет много вариантов.

=== Планировщик в реальном времени ===

Если rtkit не работает, вы можете вручную настроить систему для запуска PulseAudio с планировщиком в реальном времени, который может помочь в производительности. Чтобы сделать это, добавьте следующие строки в {{ic|/etc/security/limits.conf}}:

 @pulse-rt - rtprio 9
 @pulse-rt - nice -11

После этого вам нужно добавить пользователя в группу {{ic|pulse-rt}}:

 # gpasswd -a <user> pulse-rt

=== Ошибка pactl "неверный параметр" с отрицательным процентным аргументом ===

Команды {{ic|pactl}}, которые принимают отрицательные процентные значения аргументов, прекращают работу с ошибкой 'недопустимый параметр/опция'. Используйте стандартный псевдо аргумент оболочки '--'  для предотвращения обработки отрицательного значения. ''Например'' {{ic|pactl set-sink-volume 1 -- -5%}}.

=== Резервное устройство не определяется ===

По умолчанию PulseAudio не использует настоящее устройство. Вместо этого он использует [https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/DefaultDevice/ "резервный вариант"], который применяется только к новым звуковым потокам. Это означает, что ранее запущенные приложения не зависят от вновь установленного резервного устройства.

{{Pkg|gnome-control-center}}, {{Pkg|mate-media}} и {{AUR|paswitch}} справятся с этим. В противном случае: 

1. Переместите старые потоки вручную в {{Pkg|pavucontrol}} на новую звуковую карту.

2. Остановите Pulse, сотрите "stream-volumes" в {{ic|~/.config/pulse}} и/или {{ic|~/.pulse}} и перезапустите Pulse. Это также сбросит громкость у приложений.

3. Отключите устройства чтения потока. Это может не понадобиться если вы используете различные звуковые карты с разными приложениями.

{{hc|/etc/pulse/default.pa|<nowiki>
load-module module-stream-restore restore_device=false
</nowiki>}}

=== Отправка большого количества пакетов RTP/UDP ===

В некоторых случаях, настройка по умолчанию может блокировать сеть отправкой очень большого количества пакетов UDP. [https://bugs.freedesktop.org/show_bug.cgi?id=44777]
Для решения этой проблемы запустите {{ic|paprefs}} и отключите "Multicast/RTP Sender".[https://bugs.launchpad.net/ubuntu/+source/pulseaudio/+bug/411688/comments/36]
