TEMPLATE = app
QT += widgets qml quick

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml

TARGET = asteroid-calendar
target.path = /usr/bin/

desktop.files = asteroid-calendar.desktop
desktop.path = /usr/share/applications

INSTALLS += target desktop
