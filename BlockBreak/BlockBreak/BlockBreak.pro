TEMPLATE = app
TARGET = BlockBreak

QT += qml quick

SOURCES += main.cpp

RESOURCES += BlockBreak.qrc

OTHER_FILES += BlockBreak.apparmor \
               BlockBreak.desktop \
               BlockBreak.png

#specify where the config files are installed to
config_files.path = /BlockBreak
config_files.files += $${OTHER_FILES}
message($$config_files.files)
INSTALLS+=config_files

# Default rules for deployment.
include(../deployment.pri)

