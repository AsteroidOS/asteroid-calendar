TARGET = asteroid-calendar
CONFIG += asteroidapp link_pkgconfig
PKGCONFIG += asteroidapp

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml EventDialog.qml MonthSelector.qml

lupdate_only{ SOURCES += i18n/asteroid-calendar.desktop.h }
TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)

target.path = /usr/bin/
INSTALLS += target
