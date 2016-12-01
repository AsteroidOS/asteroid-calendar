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
              MonthSelector.qml
}

TARGET = asteroid-calendar
target.path = /usr/bin/

desktop.files = asteroid-calendar.desktop
desktop.path = /usr/share/applications

INSTALLS += target desktop
