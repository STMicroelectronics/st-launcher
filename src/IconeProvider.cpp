#include "IconeProvider.h"

#include <QDebug>
#include <QDir>
#include <QFileInfo>
#include <QIcon>
#include <QStandardPaths>

#define DEBUG 1

IconProvider::IconProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap) {
  // First directory $HOME/icons
  QString path = QDir::home().filePath(ICONPROVIDER_HOME_ICONS_PATH);
  if (QFile::exists(path))
    m_iconDirs.append(path);

  // Add XDG_DATA_DIRS icons/.icons to paths
  QStringList xdgPaths =
      QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
  xdgPaths.append(QStandardPaths::standardLocations(
      QStandardPaths::DesktopLocation)); // Add Desktop to search path
  for (const auto &dir : qAsConst(xdgPaths)) {
    const auto _dir = dir;
    // XDG_DATA_DIRS/.local/share/icons
    path = QDir(dir).filePath(ICONPROVIDER_LOCAL_ICONS_PATH);
    if (QFile::exists(path))
      m_iconDirs.append(path);
    // XDG_DATA_DIRS/icons
    path = QDir(_dir).filePath(ICONPROVIDER_ICONS_PATH);
    if (QFile::exists(path))
      m_iconDirs.append(path);
  }

  // Add $HOME/.local/share/icons path
  path = QDir::home().filePath(ICONPROVIDER_LOCAL_ICONS_PATH);
  if (QFile::exists(path))
    m_iconDirs.append(path);

  // Add /usr/share/pixmaps path last
  path = ICONPROVIDER_PIXMAPS_PATH;
  if (QFile::exists(path))
    m_iconDirs.append(path);

  // Store original theme and add other themes to search icons for
  m_themeName = QIcon::themeName();
  m_themeList << QIcon::themeName() << ICONPROVIDER_LOOKUP_THEMES;
  m_themeList.removeDuplicates();
  m_iconDirs.removeDuplicates();

  QIcon::setThemeSearchPaths(m_iconDirs);
}

QPixmap IconProvider::requestPixmap(const QString &id, QSize *size,
                                    const QSize &requestedSize) {
  Q_UNUSED(size);
  Q_UNUSED(requestedSize);

  // If the icon search string is empty ( it was not set ) the return unknown
  // icon
  if (id.isEmpty() || id == "")
    return defaultIcon();

  // If it is a full path ( begins with / )
  if (id.contains(QRegExp("^/"))) {
    // if it exist then load it from the path and return it
    QString iconPath = lookupIconExtension(id);
    if (!iconPath.isEmpty())
      return QPixmap(iconPath);
  }

  // Lookup the icon
  QPixmap themeIcon = this->searchIcon(id);
  if (!themeIcon.isNull())
    return themeIcon;

// No icon found report it and return default unknown icon
#ifdef DEBUG
  qDebug() << "No icon found for key:" << id;
#endif // DEBUG
  return defaultIcon();
}

QPixmap IconProvider::defaultIcon() const {
  // Return unknown icon
  return QPixmap(searchIcon(ICONPROVIDER_UNKNOWN_ICON));
}

QPixmap IconProvider::searchIcon(QString search) const {
  // Strip extensions
  // ( for ex.: java apps have icons specified as sun-jcontrol-jdk8.png )
  for (const auto &ext : qAsConst(m_iconExtensions))
    if (search.endsWith(QString(".").append(ext)))
      search.chop(4);

  // Lookup in themes
  for (const auto &themeName : qAsConst(m_themeList)) {
    QIcon::setThemeName(themeName);
    if (QIcon::hasThemeIcon(search))
      return QIcon::fromTheme(search).pixmap(QSize(128, 128));
  }
  QIcon::setThemeName(m_themeName);

  // Lookup in theme paths added in constructor in order
  for (const auto &iconDir : qAsConst(m_iconDirs)) {
    QString iconPath =
        lookupIconExtension(QString("%1/%2").arg(iconDir, search));
    if (!iconPath.isEmpty())
      return QPixmap(iconPath);
  }
  return QPixmap(); // Fallback
}

QString IconProvider::lookupIconExtension(QString icon) const {
  if (QFile::exists(icon))
    return icon; // If the file exists with its extension return it
  QString iconPath;
  for (const auto &ext : qAsConst(m_iconExtensions))
    if (QFile(iconPath = QString("%1.%2").arg(icon, ext))
            .exists()) // Try to lookup the file with every extensions
      return iconPath;
  return QString(); // No match found
}
