#include "PlatformData.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>

// Default for STM32MP25xx device description
static const char *DEFAULT_PLATFORM_DESC =
    "<font family=\"DejaVu Sans Mono,Ubuntu Sans Mono,Noto Sans Mono\" color=\"lightgrey\"> \
                                           The <b>STM32MP25xx</b> devices embedd two Coprocessors ARM&#174; <i>Cortex&#174;-M0+</i> \
    | ARM&#174; <i>Cortex&#174;-M33</i> cores and a Dual ARM&#174; <i>Cortex&#174;-A35</i> cores. \
    </font>";

PlatformData::PlatformData(QObject *parent) : QObject(parent) {
  // First directory $HOME/.config
  QString path = QDir::home().filePath(PLATFORMDATA_HOME_CONFIG_PATH);
  if (QFile::exists(path))
    m_descFileDirs.append(path);

  // Add /usr/share/configs path last
  path = PLATFORMDATA_CONFIG_PATH;
  if (QFile::exists(path))
    m_descFileDirs.append(path);

  // Add $HOME/Desktop local/config and .config to search path
  QStringList desktopPath =
      QStandardPaths::standardLocations(QStandardPaths::DesktopLocation);
  for (const auto &dir : qAsConst(desktopPath)) {
    const auto _dir = dir;
    // $HOME/Desktop/.config
    path = QDir(dir).filePath(PLATFORMDATA_HOME_CONFIG_PATH);
    if (QFile::exists(path))
      m_descFileDirs.append(path);

    // $HOME/Desktop/local/config
    path = QDir(_dir).filePath(ICONPROVIDER_LOCAL_CONFIG_PATH);
    if (QFile::exists(path))
      m_descFileDirs.append(path);
  }

  // Remove duplicates
  m_descFileDirs.removeDuplicates();

  for (int i = 0; i < m_descFileDirs.size(); ++i) {
    const QString fileName =
        QDir(m_descFileDirs.at(i)).filePath(PLATFORMDATA_LOCAL_DESC_FILENAME);

    if (QFile::exists(fileName)) {
      m_PlatformDescription.append(fileName);
      break; // Ok we found suitable file
    }
  }
}

PlatformData::~PlatformData() {}

bool PlatformData::isSimulator() {
#ifdef Q_OS_WINDOWS
  return true;
#else
  return false;
#endif
}

QString PlatformData::readDesc() {
  QFile file(m_PlatformDescription);
  QString fileContent;
  if (file.open(QIODevice::ReadOnly)) {
    QString line;
    QTextStream t(&file);
    do {
      line = t.readLine();
      fileContent += line;
    } while (!line.isNull());

    file.close();
  } else {
    return QString(DEFAULT_PLATFORM_DESC);
  }
  return fileContent;
}
