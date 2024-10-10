#include "ApplicationFinder.h"

void ApplicationFinder::work() {
  QStringList appdirs = QStandardPaths::standardLocations(
      QStandardPaths::ApplicationsLocation); // XDG Default applications
                                             // location, user local folder
                                             // first
  appdirs.append(QStandardPaths::standardLocations(
      QStandardPaths::DesktopLocation)); // Add Desktop to search path
  QStringList loadedFiles;
  static QRegularExpression removeKey("^.*applications/");

  for (const auto &appdir : qAsConst(appdirs)) {
    QDirIterator appdirIterator(
        appdir, QStringList(APPLICATIONS_FILES_GLOB), QDir::Files,
        QDirIterator::Subdirectories | QDirIterator::FollowSymlinks);
    while (!appdirIterator.next().isEmpty()) {
      QString fileKey = appdirIterator.filePath().remove(removeKey);
      if (!loadedFiles.contains(fileKey)) {
        Application *app = new Application(appdirIterator.filePath());
        if (app->parse()) {
          emit appFound(app);
          loadedFiles.append(fileKey);
        } else {
          DEBUG_MSG("Parsing file FAILED!");
          delete app;
        }
      }
    }
  }
  appdirs.clear();
}

ApplicationFinder::ApplicationFinder(QObject *parent) : QObject(parent) {}

ApplicationFinder::~ApplicationFinder() {
  if (m_thread.isRunning())
    m_thread.cancel();
}

void ApplicationFinder::run() {
#if QT_VERSION >= 0x060000
  m_thread = QtConcurrent::run(&ApplicationFinder::work, this);
#else
  m_thread = QtConcurrent::run(this, &ApplicationFinder::work);
#endif
  m_thread_watcher.setFuture(m_thread);
  connect(&m_thread_watcher, SIGNAL(finished()), this, SLOT(workFinished()));
}

void ApplicationFinder::workFinished() { emit isReady(); }
