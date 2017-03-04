TEMPLATE = app
QT += qml quick
CONFIG += link_pkgconfig
PKGCONFIG += qdeclarative5-boostable

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml EventDialog.qml MonthSelector.qml

lupdate_only{
    SOURCES = main.qml \
              EventDialog.qml \
              MonthSelector.qml \
              i18n/asteroid-calendar.desktop.h
}

# Needed for lupdate
TRANSLATIONS = i18n/asteroid-calendar.ca.ts \
               i18n/asteroid-calendar.de.ts \
               i18n/asteroid-calendar.el.ts \
               i18n/asteroid-calendar.es.ts \
               i18n/asteroid-calendar.fa.ts \
               i18n/asteroid-calendar.fr.ts \
               i18n/asteroid-calendar.hu.ts \
               i18n/asteroid-calendar.it.ts \
               i18n/asteroid-calendar.kab.ts \
               i18n/asteroid-calendar.ko.ts \
               i18n/asteroid-calendar.nl.ts \
               i18n/asteroid-calendar.pl.ts \
               i18n/asteroid-calendar.pt_BR.ts \
               i18n/asteroid-calendar.ru.ts \
               i18n/asteroid-calendar.sv.ts \
               i18n/asteroid-calendar.ta.ts \
               i18n/asteroid-calendar.tr.ts \
               i18n/asteroid-calendar.uk.ts \
               i18n/asteroid-calendar.zh_Hans.ts

TARGET = asteroid-calendar
target.path = /usr/bin/

desktop.commands = bash $$PWD/i18n/generate-desktop.sh $$PWD asteroid-calendar.desktop
desktop.files = $$OUT_PWD/asteroid-calendar.desktop
desktop.path = /usr/share/applications
desktop.CONFIG = no_check_exist

INSTALLS += target desktop
