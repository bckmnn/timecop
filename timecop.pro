TEMPLATE = app

QT += qml quick widgets
CONFIG += c++11

SOURCES += main.cpp \
    systrayhelper.cpp

ICON = appIcon.icns

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    systrayhelper.h

QMAKE_POST_LINK += "defaults write /Users/beckmst/Documents/repos/build-timecop-Desktop_Qt_5_5_1_clang_64bit-Release/timecop.app/Contents/Info LSUIElement 1"
