TARGET = asteroid-calendar
CONFIG += asteroidapp

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml EventDialog.qml MonthSelector.qml

lupdate_only{
    SOURCES = main.qml \
              EventDialog.qml \
              MonthSelector.qml \
              i18n/$$TARGET.desktop.h
}
TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)
