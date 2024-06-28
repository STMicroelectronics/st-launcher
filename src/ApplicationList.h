#ifndef APPLICATIONLIST_H
#define APPLICATIONLIST_H

#include "Application.h"
#include "ApplicationFinder.h"
#include <QAbstractListModel>
#include <QList>

/**
 * @brief The Applications class
 *
 * Generates a list of applications from desktop files
 *
 */
class ApplicationList : public QAbstractListModel {
  Q_OBJECT
  Q_DISABLE_COPY(ApplicationList)
  Q_PROPERTY(int count READ count NOTIFY countChanged)

  ApplicationFinder m_finder;
  QList<Application *> *m_data;

public:
  enum Roles {
    IconRole = Qt::UserRole + 1,
    SearchRole,
    CommentRole,
    IsIgnoredRole
  };
  explicit ApplicationList(QObject *parent = 0);
  virtual ~ApplicationList();

  int count() const;
  bool running() const;
  bool ready() const;
  Q_INVOKABLE QObject *get(int index);
  Q_INVOKABLE bool remove(Application *item, const QModelIndex &parent);
  Q_INVOKABLE bool add_new(QString filePath);

  virtual int rowCount(const QModelIndex & = QModelIndex()) const;
  virtual QVariant data(const QModelIndex &index,
                        int role = Qt::DisplayRole) const;
  virtual QHash<int, QByteArray> roleNames() const;
  virtual bool insertRow(int row, const QModelIndex &parent = QModelIndex());
  virtual bool removeRow(int row, const QModelIndex &parent = QModelIndex());

  int pageNumber() const;
  int pageSize() const;

  bool m_running = false;
  bool m_ready = false;
signals:
  void countChanged();
  void runningChanged(QVariant running);
  void readyChanged(QVariant ready);
  void appErrorSignal(QString msg, int itemIndex);
  void errorMessageChanged(QVariant msg);

private slots:
  void append(Application *item);

public slots:
  void appRunning(bool running, QPointer<QProcess> *p);
  void appsReady();
  void appErrorSlot(QString msg, int itemIndex);
  void exitHandler();

private:
  int m_pageNumber;
  int m_pageSize;
};

#endif // APPLICATIONLIST_H
