#include "ApplicationFilter.h"
#include "ApplicationList.h"

#include <QByteArray>
#include <QHash>

ApplicationFilter::ApplicationFilter(QObject *parent)
    : QSortFilterProxyModel{parent} {
  m_filter_name = "";
  m_show_ignored = false;
}

QObject *ApplicationFilter::get(QModelIndex index) {
  QModelIndex source = this->mapToSource(index);
  return ((ApplicationList *)this->sourceModel())->get(source.row());
}

bool ApplicationFilter::run_app(QModelIndex index) {
  Application * app = static_cast<Application *>(this->get(index));
  if (app)
      return app->run(app->exec());
  else
      return false;
}

bool ApplicationFilter::remove(QModelIndex index) {
  bool success = false;
  QModelIndex source = this->mapToSource(index);
  Application *item = (Application *)((ApplicationList *)this->sourceModel())->get(source.row());
  qDebug() << "Removing Item " << item << " (Index: ) " << index;
  success = ((ApplicationList *)this->sourceModel())->remove(item, index);
  invalidateFilter();

  return success;
}

bool ApplicationFilter::add_new(QString filePath) {
  return ((ApplicationList *)this->sourceModel())->add_new(filePath);
}

void ApplicationFilter::setFilterName(QString f) {
  m_filter_name = f;
  invalidateFilter();
}

void ApplicationFilter::setFilterShowIgnored(bool showIgnored) {
  m_show_ignored = showIgnored;
  invalidateFilter();
}

void ApplicationFilter::toggleFilterShowIgnored() {
  m_show_ignored = !m_show_ignored;
  invalidateFilter();
}

bool ApplicationFilter::filterAcceptsRow(
    int sourceRow, const QModelIndex &sourceParent) const {
  QModelIndex indexItem = sourceModel()->index(sourceRow, 0, sourceParent);
  bool isIgnored =
      sourceModel()->data(indexItem, ApplicationList::IsIgnoredRole).toBool();

  bool show_item = ((isIgnored && m_show_ignored) || !isIgnored) &&
                   (sourceModel()
                        ->data(indexItem, ApplicationList::SearchRole)
                        .toString()
                        .contains(m_filter_name, Qt::CaseInsensitive));

  return show_item;
}

bool ApplicationFilter::lessThan(const QModelIndex &left,
                                 const QModelIndex &right) const {
  return QString::localeAwareCompare(
             sourceModel()->data(left, Qt::DisplayRole).toString(),
             sourceModel()->data(right, Qt::DisplayRole).toString()) < 0;
}
