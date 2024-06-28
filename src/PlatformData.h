#ifndef PLATFORMDATA_H
#define PLATFORMDATA_H

#include <QObject>

#define PLATFORMDATA_HOME_CONFIG_PATH ".config"
#define ICONPROVIDER_LOCAL_CONFIG_PATH ".local/share/config"
#define PLATFORMDATA_CONFIG_PATH "/usr/share/config/"
#define PLATFORMDATA_LOCAL_DESC_FILENAME "platformdata.txt"

class PlatformData : public QObject {
  Q_OBJECT
public:

  explicit PlatformData(QObject *parent = 0);
  virtual ~PlatformData();

  Q_INVOKABLE QString readDesc();
  Q_INVOKABLE bool isSimulator();

private:
  QString m_PlatformDescription;
  QStringList m_descFileDirs;
};

#endif // PLATFORMDATA_H
