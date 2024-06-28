TEMPLATE = app

QT += quick
QT += qml quickcontrols2
CONFIG += c++11 link_pkgconfig

QT_FOR_CONFIG += virtualkeyboard

#CONFIG += disable-desktop
contains(CONFIG, static) {
    QT += svg
    QTPLUGIN += qtvirtualkeyboardplugin
}

#CONFIG += console

HEADERS += \
    $$files(src/*.h) \
    $$files(src/*.hpp)

SOURCES += \
    $$files(src/*.c) \
    $$files(src/*.cpp)

RESOURCES += \
    $$files(qml/*)

#RESOURCES += qml.qrc \
#    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = qml/imports

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH = qml/imports

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
#DEFINES += QT_DEPRECATED_WARNINGS

DEFINES += QT_IM_MODULE="qtvirtualkeyboard"
DEFINES += QT_VIRTUALKEYBOARD_DESKTOP_DISABLE=1

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /usr/share/qt/$${TARGET}-1.0
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    qml/content/CustomBusyIndicator.qml \
    qml/content/CustomBusyIndicatorStyle.qml \
    qml/content/Information.qml \
    qml/content/LoadingScreen.qml \
    qml/content/Setting.qml \
    qml/content/StmInfo.qml

