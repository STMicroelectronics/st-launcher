#include "ApplicationList.h"

#include <QDir>
#include <QWindow>

ApplicationList::ApplicationList(QObject *parent) : QAbstractListModel(parent) {
  m_data = new QList<Application *>();
  connect(&m_finder, SIGNAL(appFound(Application*)), this,
          SLOT(append(Application*)));
  connect(&m_finder, SIGNAL(isReady()), this, SLOT(appsReady()));
  m_finder.run();
}

ApplicationList::~ApplicationList() {
  qDeleteAll(*this->m_data);
  delete m_data;
}

int ApplicationList::count() const { return m_data->count(); }

bool ApplicationList::running() const { return m_running; }

bool ApplicationList::ready() const { return m_ready; }

QObject *ApplicationList::get(int index) { return m_data->at(index); }

int ApplicationList::rowCount(const QModelIndex &) const { return count(); }

QVariant ApplicationList::data(const QModelIndex &index, int role) const {
  if (!index.isValid())
    return QVariant();
  if (index.row() > (m_data->size() - 1))
    return QVariant();

  Application *obj = m_data->at(index.row());
  switch (role) {
  case Qt::DisplayRole:
    return QVariant::fromValue(obj->nameLocalized());
  case SearchRole:
    return QVariant::fromValue(obj->searchTerms().join(" "));
  case IconRole:
    return QVariant::fromValue(obj->icon());
  case CommentRole:
    return QVariant::fromValue(obj->comment());
  case IsIgnoredRole:
    return QVariant::fromValue(obj->isIgnored());
  default:
    return QVariant();
  }
}

QHash<int, QByteArray> ApplicationList::roleNames() const {
  QHash<int, QByteArray> roles = QAbstractListModel::roleNames();
  roles.insert(IconRole, QByteArray("icon"));
  roles.insert(SearchRole, QByteArray("search"));
  roles.insert(CommentRole, QByteArray("comment"));
  roles.insert(IsIgnoredRole, QByteArray("ignored"));
  return roles;
}

void ApplicationList::append(Application *item) {
  if (!item->isIgnored()) {
    m_data->append(item);
    if (insertRow(m_data->count() - 1)) // This will trig sorting action
    {
      // Connect signal to catch App execution status
      connect(item, SIGNAL(AppRunning(bool,QPointer<QProcess>*)), this, SLOT(appRunning(bool,QPointer<QProcess>*)));
      connect(item, SIGNAL(AppError(const QString,int)), this, SLOT(appErrorSlot(const QString,int)));
    }
  } else {
    DEBUG_MSG("Ignoring Item " << item->name());
  }
}

bool ApplicationList::remove(Application *item, const QModelIndex &parent) {
  bool success = false;
  if (!item->isIgnored()) {
    DEBUG_MSG("Removing Item " << item->name() << " Index " << parent << " Row : " << parent.row());
    if (removeRow(parent.row(), parent)) // This will trig sorting action
    {
      DEBUG_MSG("Item " << item->name() << " Removed.");
    }
    success = m_data->removeOne(item);
  }

  return success;
}

bool ApplicationList::add_new(QString filePath) {
  bool success = false;

  // TODO: parse and install .deb package using aptitude
  // TODO: retreive the name of the .desktop file from the .deb package file
  Application *app = new Application(filePath);
  if (app->build()) {
    append(app);
    success = true;
  } else
    delete app;

  return success;
}

bool ApplicationList::insertRow(int row, const QModelIndex &parent) {
  beginInsertRows(parent, row, row);
  insertRows(row, m_data->count(), parent);
  endInsertRows();
  emit countChanged();
  return true;
}

bool ApplicationList::removeRow(int row, const QModelIndex &parent) {
  emit layoutAboutToBeChanged();
  beginRemoveRows(parent, row, row);
  removeRows(row, m_data->count(), parent);
  endRemoveRows();
  //emit countChanged();
  changePersistentIndex(parent, parent);
  emit layoutChanged();
  return true;
}

void ApplicationList::appsReady() {
  DEBUG_MSG("Apps Ready" << " (Total: ) " << m_data->count());
  m_ready = true; // Now we can go 'home' and show the list
  emit readyChanged(true);
}

void ApplicationList::appRunning(bool running, QPointer<QProcess> *p) {
  m_running = running;
  emit runningChanged(running);
  if(p && *p && !running) {
    DEBUG_MSG("Process Exited");
    // Wait for the process to gracefully finish before deleting the pointer!
    (*p)->waitForFinished(-1);
    (*p)->deleteLater();
    delete *p;
    *p = 0;
  }
}

void ApplicationList::appErrorSlot(const QString msg, int itemIndex) {
  if (count() > itemIndex) {
    Application *item = reinterpret_cast<Application *>(get(itemIndex));
    DEBUG_MSG("Called the C++ slot with message: " << msg << " for Item index: " << itemIndex);
    item->processExited(0,QProcess::NormalExit);
    emit errorMessageChanged(msg);
  }
}

void ApplicationList::exitHandler()
{
  DEBUG_MSG("Called the C++ Exit slot");

  for (int32_t itemIndex=0; itemIndex < count(); itemIndex++) {
    Application *item = reinterpret_cast<Application *>(get(itemIndex));
    if (item) {
      DEBUG_MSG("Killing the process " << itemIndex);
      item->exitProcess();
    }
  }

  DEBUG_MSG("STLauncher is about to close now");
}
